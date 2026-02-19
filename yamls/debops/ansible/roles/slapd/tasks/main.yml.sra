(playbook "debops/ansible/roles/slapd/tasks/main.yml"
  (tasks
    (task "Import custom Ansible plugins"
      (ansible.builtin.import_role 
        (name "ansible_plugins")))
    (task "Import DebOps global handlers"
      (ansible.builtin.import_role 
        (name "global_handlers")))
    (task "Import DebOps secret role"
      (ansible.builtin.import_role 
        (name "secret")))
    (task "Prepare OpenLDAP installation to use the rfc2307bis schema"
      (ansible.builtin.include_tasks "prepare_rfc2307bis.yml")
      (when "(slapd__rfc2307bis_enabled | bool and (ansible_local is undefined or ansible_local.slapd is undefined))"))
    (task "Initialize BaseDN value in debconf using a DNS domain"
      (ansible.builtin.debconf 
        (name "slapd")
        (question (jinja "{{ item }}"))
        (vtype "string")
        (value (jinja "{{ slapd__domain }}")))
      (loop (list
          "slapd/domain"
          "shared/organization")))
    (task "Install OpenLDAP packages"
      (ansible.builtin.package 
        (name (jinja "{{ q(\"flattened\", (slapd__base_packages
                              + slapd__schema_packages
                              + slapd__packages)) }}"))
        (state "present"))
      (register "slapd__register_packages")
      (until "slapd__register_packages is succeeded"))
    (task "Allow access to additional UNIX groups by the OpenLDAP service"
      (ansible.builtin.user 
        (name (jinja "{{ slapd__user }}"))
        (groups (jinja "{{ slapd__additional_groups }}"))
        (append "True")
        (state "present"))
      (register "slapd__register_unix_groups"))
    (task "Divert the OpenLDAP environment file"
      (debops.debops.dpkg_divert 
        (path "/etc/default/slapd")))
    (task "Generate the OpenLDAP environment file"
      (ansible.builtin.template 
        (src "etc/default/slapd.j2")
        (dest "/etc/default/slapd")
        (mode "0644"))
      (register "slapd__register_environment"))
    (task "Restart slapd if its configuration was modified"
      (ansible.builtin.service 
        (name "slapd")
        (state "restarted"))
      (when "slapd__register_unix_groups is changed or slapd__register_environment is changed"))
    (task "Ensure that the log directory exists"
      (ansible.builtin.file 
        (path (jinja "{{ slapd__log_dir }}"))
        (state "directory")
        (owner (jinja "{{ slapd__user }}"))
        (group (jinja "{{ slapd__group }}"))
        (mode "0750")))
    (task "Install helper scripts"
      (ansible.builtin.copy 
        (src "usr/local/sbin/")
        (dest "/usr/local/sbin/")
        (mode "0755"))
      (tags (list
          "role::slapd:scripts")))
    (task "Ensure that DebOps schema directory exists"
      (ansible.builtin.file 
        (path (jinja "{{ slapd__debops_schema_path }}"))
        (state "directory")
        (mode "0755")))
    (task "Copy custom DebOps schemas to the OpenLDAP host"
      (ansible.builtin.copy 
        (src "etc/ldap/schema/debops/")
        (dest (jinja "{{ slapd__debops_schema_path + \"/\" }}"))
        (mode "0644")))
    (task "Load custom LDAP schemas"
      (ansible.builtin.script "script/ldap-load-schema " (jinja "{{ item }}"))
      (loop (jinja "{{ q(\"flattened\", slapd__combined_schemas) }}"))
      (register "slapd__register_load_schemas")
      (changed_when "(slapd__register_load_schemas.stdout | d() and (item | basename | regex_replace('.schema$', '') + ' already exists in the LDAP, skipping…') not in slapd__register_load_schemas.stdout_lines)")
      (tags (list
          "role::slapd:schema")))
    (task "Ensure that additional database directories exist"
      (ansible.builtin.file 
        (path (jinja "{{ item }}"))
        (state "directory")
        (owner (jinja "{{ slapd__user }}"))
        (group (jinja "{{ slapd__group }}"))
        (mode "0755"))
      (loop (jinja "{{ slapd__additional_database_dirs }}")))
    (task "Configure backup snapshots as cron jobs"
      (ansible.builtin.cron 
        (name "Create " (jinja "{{ item }}") " backup snapshots of OpenLDAP databases")
        (special_time (jinja "{{ item }}"))
        (cron_file "slapd-snapshot")
        (user "root")
        (state (jinja "{{ slapd__snapshot_deploy_state
               if (item in slapd__snapshot_cron_jobs)
               else \"absent\" }}"))
        (job "/usr/local/sbin/slapd-snapshot " (jinja "{{ item }}")))
      (loop (list
          "daily"
          "weekly"
          "monthly"))
      (loop_control 
        (label (jinja "{{ {\"state\": (slapd__snapshot_deploy_state
                          if (item in slapd__snapshot_cron_jobs)
                          else \"absent\"),
                \"cron_job\": item} }}"))))
    (task "Make sure that Ansible local facts directory exists"
      (ansible.builtin.file 
        (path "/etc/ansible/facts.d")
        (state "directory")
        (mode "0755")))
    (task "Save OpenLDAP server local facts"
      (ansible.builtin.template 
        (src "etc/ansible/facts.d/slapd.fact.j2")
        (dest "/etc/ansible/facts.d/slapd.fact")
        (mode "0755"))
      (notify (list
          "Refresh host facts"))
      (tags (list
          "meta::facts")))
    (task "Update Ansible facts if they were modified"
      (ansible.builtin.meta "flush_handlers"))
    (task "Perform OpenLDAP tasks"
      (ansible.builtin.include_tasks "slapd_tasks.yml")
      (loop (jinja "{{ q(\"flattened\", slapd__combined_tasks) | debops.debops.parse_kv_items }}"))
      (loop_control 
        (label (jinja "{{ {\"state\": item.state,
                \"dn\": item.dn,
                \"attributes\": item.attributes | d({})} }}")))
      (when "item.name | d() and item.dn | d() and item.state | d('present') not in [ 'init', 'ignore' ]")
      (tags (list
          "role::slapd:tasks"))
      (no_log (jinja "{{ debops__no_log | d(item.no_log)
              | d(True
                  if (\"userPassword\" in (item.attributes | d({})).keys() or
                      \"olcRootPW\" in (item.attributes | d({})).keys())
                  else False) }}")))
    (task "Remove slapacl test suite if requested"
      (ansible.builtin.file 
        (path (jinja "{{ slapd__slapacl_script }}"))
        (state "absent"))
      (when "slapd__slapacl_deploy_state == 'absent'")
      (tags (list
          "role::slapd:slapacl"
          "role::slapd:tasks")))
    (task "Perform OpenLDAP slapacl tasks"
      (ansible.builtin.include_tasks "slapd_tasks.yml")
      (loop (jinja "{{ q(\"flattened\", slapd__slapacl_combined_tasks) | debops.debops.parse_kv_items }}"))
      (loop_control 
        (label (jinja "{{ {\"state\": item.state,
                \"dn\": item.dn,
                \"attributes\": item.attributes | d({})} }}")))
      (when "slapd__slapacl_deploy_state == 'present' and item.name | d() and item.dn | d() and item.state | d('present') not in [ 'init', 'ignore' ]")
      (tags (list
          "role::slapd:slapacl"
          "role::slapd:tasks"))
      (no_log (jinja "{{ debops__no_log | d(item.no_log)
              | d(True
                  if (\"userPassword\" in (item.attributes | d({})).keys() or
                      \"olcRootPW\" in (item.attributes | d({})).keys())
                  else False) }}")))
    (task "Generate slapacl test suite script"
      (ansible.builtin.template 
        (src "etc/ldap/slapacl-test-suite.j2")
        (dest (jinja "{{ slapd__slapacl_script }}"))
        (group (jinja "{{ slapd__group }}"))
        (mode "0750"))
      (register "slapd__register_slapacl_script")
      (when "slapd__slapacl_deploy_state == 'present'")
      (tags (list
          "role::slapd:slapacl"
          "role::slapd:tasks")))
    (task "Test ACL rules using slapacl"
      (ansible.builtin.command (jinja "{{ slapd__slapacl_script }}"))
      (environment 
        (SLAPACL_STDOUT "false"))
      (become "True")
      (become_user (jinja "{{ slapd__user }}"))
      (register "slapd__register_slapacl_test")
      (when "slapd__slapacl_deploy_state == 'present' and slapd__slapacl_run_tests | bool")
      (changed_when "slapd__register_slapacl_test.stderr | d()")
      (tags (list
          "role::slapd:slapacl"
          "role::slapd:tasks")))))
