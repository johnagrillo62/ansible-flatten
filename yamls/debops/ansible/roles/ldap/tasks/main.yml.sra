(playbook "debops/ansible/roles/ldap/tasks/main.yml"
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
    (task "Take note of the current LDAP configuration"
      (ansible.builtin.set_fact 
        (ldap__fact_configured (jinja "{{ ldap__configured }}"))
        (ldap__fact_dependent_tasks (jinja "{{ ldap__dependent_tasks }}")))
      (tags (list
          "role::ldap:tasks"
          "skip::ldap:tasks")))
    (task "Install packages required for LDAP support"
      (ansible.builtin.package 
        (name (jinja "{{ q(\"flattened\", ldap__base_packages + ldap__packages) }}"))
        (state "present"))
      (register "ldap__register_packages")
      (until "ldap__register_packages is succeeded")
      (when "ldap__enabled | bool and not ldap__dependent_play | bool"))
    (task "Divert original LDAP client configuration"
      (debops.debops.dpkg_divert 
        (path "/etc/ldap/ldap.conf"))
      (when "ldap__enabled | bool and not ldap__dependent_play | bool"))
    (task "Generate system-wide LDAP configuration"
      (ansible.builtin.template 
        (src "etc/ldap/ldap.conf.j2")
        (dest "/etc/ldap/ldap.conf")
        (mode "0644"))
      (notify (list
          "Refresh host facts"))
      (when "ldap__enabled | bool and not ldap__dependent_play | bool"))
    (task "Make sure that Ansible local facts directory exists"
      (ansible.builtin.file 
        (path "/etc/ansible/facts.d")
        (state "directory")
        (mode "0755"))
      (when "ldap__enabled | bool and not ldap__dependent_play | bool"))
    (task "Save LDAP client local facts"
      (ansible.builtin.template 
        (src "etc/ansible/facts.d/ldap.fact.j2")
        (dest "/etc/ansible/facts.d/ldap.fact")
        (mode "0755"))
      (notify (list
          "Refresh host facts"))
      (when "ldap__enabled | bool and not ldap__dependent_play | bool")
      (tags (list
          "meta::facts")))
    (task "Update Ansible facts if they were modified"
      (ansible.builtin.meta "flush_handlers"))
    (task "Check if LDAP admin password is available"
      (ansible.builtin.set_fact 
        (ldap__fact_admin_bindpw (jinja "{{ ldap__admin_bindpw }}")))
      (become (jinja "{{ ldap__admin_become }}"))
      (become_user (jinja "{{ ldap__admin_become_user }}"))
      (delegate_to (jinja "{{ ldap__admin_delegate_to }}"))
      (run_once "True")
      (tags (list
          "role::ldap:tasks"
          "skip::ldap:tasks")))
    (task "Perform LDAP tasks"
      (ansible.builtin.include_tasks "ldap_tasks.yml")
      (loop (jinja "{{ q(\"flattened\", ldap__combined_tasks) | debops.debops.parse_kv_items }}"))
      (loop_control 
        (label (jinja "{{ {\"state\": item.state,
                \"dn\": item.dn,
                \"attributes\": item.attributes | d({})} }}")))
      (when "ldap__enabled | bool and ldap__admin_enabled | bool and item.name | d() and item.dn | d() and item.state | d('present') not in [ 'init', 'ignore' ]")
      (tags (list
          "role::ldap:tasks"
          "skip::ldap:tasks"))
      (no_log (jinja "{{ debops__no_log | d(item.no_log | d(True
                                 if (\"userPassword\" in (item.attributes | d({})).keys() or
                                     \"olcRootPW\" in (item.attributes | d({})).keys())
                                 else False)) }}")))))
