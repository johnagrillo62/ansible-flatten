(playbook "debops/ansible/roles/icinga_web/tasks/main.yml"
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
    (task "Assert that the DB types are valid"
      (ansible.builtin.assert 
        (that (list
            "icinga_web__database_map[icinga_web__database_type].db_name is defined"
            "icinga_web__director_enabled | d(False) | bool == False or icinga_web__director_database_map[icinga_web__director_database_type].db_name is defined"
            "icinga_web__x509_enabled | d(False) | bool == False or icinga_web__x509_database_map[icinga_web__x509_database_type].db_name is defined")))
      (become "False")
      (run_once "True")
      (delegate_to "localhost"))
    (task "Install required Icinga Web packages"
      (ansible.builtin.package 
        (name (jinja "{{ q(\"flattened\", icinga_web__base_packages + icinga_web__packages) }}"))
        (state "present"))
      (register "icinga_web__register_packages")
      (until "icinga_web__register_packages is succeeded"))
    (task "Get current Icinga Web configuration"
      (ansible.builtin.script "script/icingaweb-config" (jinja "{{ \"2\" if (ansible_python_version is version_compare(\"3.5\", \"<\")) else \"3\" }}"))
      (register "icinga_web__register_config")
      (changed_when "False")
      (check_mode "False"))
    (task "Ensure that configuration directories exist"
      (ansible.builtin.file 
        (path "/etc/icingaweb2/" (jinja "{{ item.name }}"))
        (state "directory")
        (owner (jinja "{{ icinga_web__user }}"))
        (group (jinja "{{ icinga_web__group }}"))
        (mode (jinja "{{ item.mode | d(\"02770\") }}")))
      (with_items (list
          
          (name "enabledModules")
          (mode "02750")
          
          (name "modules/monitoring")
          
          (name "modules/director")
          
          (name "modules/x509")))
      (when "item.state | d('present') not in ['absent', 'ignore', 'init']"))
    (task "Download and install Icinga upstream modules"
      (ansible.builtin.git 
        (repo (jinja "{{ item.git_repo }}"))
        (dest (jinja "{{ icinga_web__src + \"/\" + item.git_repo.split(\"://\")[1] }}"))
        (version (jinja "{{ item.git_version }}")))
      (with_items (jinja "{{ (icinga_web__default_modules + icinga_web__modules) | debops.debops.parse_kv_items }}"))
      (when "item.name | d() and item.git_repo | d() and item.git_version | d() and item.state | d('present') != 'absent'"))
    (task "Symlink Icinga upstream modules to Icinga Web application"
      (ansible.builtin.file 
        (path (jinja "{{ \"/usr/share/icingaweb2/modules/\" + item.name }}"))
        (src (jinja "{{ icinga_web__src + \"/\" + item.git_repo.split(\"://\")[1] }}"))
        (state "link")
        (force (jinja "{{ True if ansible_check_mode | bool else omit }}"))
        (mode "0755"))
      (with_items (jinja "{{ (icinga_web__default_modules + icinga_web__modules) | debops.debops.parse_kv_items }}"))
      (when "item.name | d() and item.git_repo | d() and item.git_version | d() and item.state | d('present') != 'absent'"))
    (task "Manage Icinga Web modules"
      (ansible.builtin.file 
        (path "/etc/icingaweb2/enabledModules/" (jinja "{{ item.name }}"))
        (src (jinja "{{ (item.path | d(\"/usr/share/icingaweb2/modules/\" + item.name))
             if (item.state | d(\"present\") != \"absent\" and (item.enabled | d(True)) | bool) else omit }}"))
        (state (jinja "{{ \"link\" if (item.state | d(\"present\") != \"absent\" and (item.enabled | d(True)) | bool) else \"absent\" }}"))
        (force (jinja "{{ True if ansible_check_mode | bool else omit }}"))
        (mode "0755"))
      (with_items (jinja "{{ (icinga_web__default_modules + icinga_web__modules) | debops.debops.parse_kv_items }}"))
      (when "item.name | d()"))
    (task "Generate Icinga Web configuration"
      (ansible.builtin.template 
        (src "etc/icingaweb2/template.ini.j2")
        (dest "/etc/icingaweb2/" (jinja "{{ item.filename }}"))
        (owner (jinja "{{ icinga_web__user }}"))
        (group (jinja "{{ icinga_web__group }}"))
        (mode "0660"))
      (no_log (jinja "{{ debops__no_log | d(item.no_log) | d(False) }}"))
      (with_items (list
          
          (filename "authentication.ini")
          (config (jinja "{{ icinga_web__combined_authentication }}"))
          
          (filename "config.ini")
          (config (jinja "{{ icinga_web__combined_config }}"))
          
          (filename "groups.ini")
          (config (jinja "{{ icinga_web__combined_groups }}"))
          
          (filename "resources.ini")
          (config (jinja "{{ icinga_web__combined_resources }}"))
          (no_log (jinja "{{ debops__no_log | d(True) }}"))
          
          (filename "roles.ini")
          (config (jinja "{{ icinga_web__combined_roles }}"))
          
          (filename "modules/monitoring/backends.ini")
          (config (jinja "{{ icinga_web__combined_backends }}"))
          
          (filename "modules/monitoring/commandtransports.ini")
          (config (jinja "{{ icinga_web__combined_commandtransports }}"))
          
          (filename "modules/director/config.ini")
          (config (jinja "{{ icinga_web__combined_director_cfg }}"))
          
          (filename "modules/director/kickstart.ini")
          (config (jinja "{{ icinga_web__combined_director_kickstart_cfg }}"))
          
          (filename "modules/x509/config.ini")
          (config (jinja "{{ icinga_web__combined_x509_cfg }}"))))
      (when "item.state | d('present') not in ['absent', 'ignore', 'init']"))
    (task "Generate initial data file"
      (ansible.builtin.template 
        (src "tmp/icingaweb-initial-data.sql.j2")
        (dest "/tmp/icingaweb-initial-data.sql")
        (owner "root")
        (group "root")
        (mode "0600"))
      (when "icinga_web__database_init | bool")
      (no_log (jinja "{{ debops__no_log | d(True) }}")))
    (task "Create Icinga Web PostgreSQL tables"
      (community.postgresql.postgresql_db 
        (name (jinja "{{ icinga_web__database_name }}"))
        (state "restore")
        (target (jinja "{{ item }}"))
        (login_host (jinja "{{ icinga_web__database_host }}"))
        (login_user (jinja "{{ icinga_web__database_user }}"))
        (login_password (jinja "{{ icinga_web__database_password }}"))
        (ssl_mode (jinja "{{ \"verify-full\" if icinga_web__database_ssl | d(False) | bool else \"disable\" }}")))
      (with_items (list
          (jinja "{{ icinga_web__database_schema }}")
          "/tmp/icingaweb-initial-data.sql"))
      (no_log (jinja "{{ debops__no_log | d(True) }}"))
      (when "icinga_web__database_type == 'postgresql' and icinga_web__database_init | bool"))
    (task "Create Icinga Web x509 PostgreSQL tables"
      (community.postgresql.postgresql_db 
        (name (jinja "{{ icinga_web__x509_database_name }}"))
        (state "restore")
        (target (jinja "{{ icinga_web__x509_database_schema }}"))
        (login_host (jinja "{{ icinga_web__x509_database_host }}"))
        (login_user (jinja "{{ icinga_web__x509_database_user }}"))
        (login_password (jinja "{{ icinga_web__x509_database_password }}"))
        (ssl_mode (jinja "{{ \"verify-full\" if icinga_web__x509_database_ssl | d(False) | bool else \"disable\" }}")))
      (no_log (jinja "{{ debops__no_log | d(True) }}"))
      (when "icinga_web__x509_enabled | bool and icinga_web__x509_database_type == 'postgresql' and icinga_web__x509_database_init | bool"))
    (task "Create Icinga Web MariaDB tables"
      (community.mysql.mysql_db 
        (name (jinja "{{ icinga_web__database_name }}"))
        (state "import")
        (target (jinja "{{ item }}"))
        (login_host (jinja "{{ icinga_web__database_host }}"))
        (login_user (jinja "{{ icinga_web__database_user }}"))
        (login_password (jinja "{{ icinga_web__database_password }}"))
        (check_hostname (jinja "{{ icinga_web__database_ssl | d(False) | bool }}")))
      (with_items (list
          (jinja "{{ icinga_web__database_schema }}")
          "/tmp/icingaweb-initial-data.sql"))
      (no_log (jinja "{{ debops__no_log | d(True) }}"))
      (when "icinga_web__database_type == 'mariadb' and icinga_web__database_init | bool"))
    (task "Create Icinga Web x509 MariaDB tables"
      (community.mysql.mysql_db 
        (name (jinja "{{ icinga_web__x509_database_name }}"))
        (state "import")
        (target (jinja "{{ icinga_web__x509_database_schema }}"))
        (login_host (jinja "{{ icinga_web__x509_database_host }}"))
        (login_port (jinja "{{ icinga_web__x509_database_port }}"))
        (login_user (jinja "{{ icinga_web__x509_database_user }}"))
        (login_password (jinja "{{ icinga_web__x509_database_password }}"))
        (check_hostname (jinja "{{ icinga_web__x509_database_ssl | d(False) | bool }}")))
      (no_log (jinja "{{ debops__no_log | d(True) }}"))
      (when "icinga_web__x509_enabled | bool and icinga_web__x509_database_type == 'mariadb' and icinga_web__x509_database_init | bool"))
    (task "Ensure that initial data schema is removed"
      (ansible.builtin.file 
        (path "/tmp/icingaweb-initial-data.sql")
        (state "absent")))
    (task "Create or migrate Icinga Director database"
      (ansible.builtin.command "icingacli director migration run")
      (register "icinga_web__register_director_migrate")
      (changed_when "icinga_web__register_director_migrate.changed | bool")
      (when "icinga_web__director_enabled | bool and icinga_web__director_database_init | bool"))
    (task "Kickstart Icinga Director configuration"
      (ansible.builtin.command "icingacli director kickstart run")
      (register "icinga_web__register_director_kickstart")
      (changed_when "icinga_web__register_director_kickstart.changed | bool")
      (when "icinga_web__director_enabled | bool and icinga_web__director_database_init | bool and icinga_web__director_kickstart_enabled | bool"))
    (task "Deploy Icinga Director configuration"
      (ansible.builtin.command "icingacli director config deploy")
      (register "icinga_web__register_director_deploy")
      (changed_when "icinga_web__register_director_deploy.changed | bool")
      (when "icinga_web__director_enabled | bool and icinga_web__director_database_init | bool and icinga_web__director_kickstart_enabled | bool"))
    (task "Create Director Unix account"
      (ansible.builtin.user 
        (name (jinja "{{ icinga_web__director_user }}"))
        (group (jinja "{{ icinga_web__director_group }}"))
        (system "True")
        (home (jinja "{{ icinga_web__director_home }}"))
        (shell (jinja "{{ icinga_web__director_shell }}"))))
    (task "Set permissions on Director home directory"
      (ansible.builtin.file 
        (path (jinja "{{ icinga_web__director_home }}"))
        (mode (jinja "{{ icinga_web__director_home_mode }}"))))
    (task "Check if old Director jobs service exists"
      (ansible.builtin.stat 
        (path "/etc/systemd/system/icinga2-director-jobs.service"))
      (register "icinga_web__register_director_jobs_service"))
    (task "Stop and disable old Director jobs service"
      (ansible.builtin.systemd 
        (name "icinga2-director-jobs.service")
        (state "stopped")
        (enabled "False"))
      (when "icinga_web__register_director_jobs_service.stat.exists"))
    (task "Remove old Director jobs service"
      (ansible.builtin.file 
        (path "/etc/systemd/system/icinga2-director-jobs.service")
        (state "absent")))
    (task "Configure Director service"
      (ansible.builtin.template 
        (src "etc/systemd/system/icinga-director.service.j2")
        (dest "/etc/systemd/system/icinga-director.service")
        (mode "0644")))
    (task "Start and enable Director service"
      (ansible.builtin.systemd 
        (daemon_reload "True")
        (name "icinga-director.service")
        (enabled "True")
        (state "started"))
      (when "icinga_web__director_enabled | bool"))
    (task "Stop and disable Director service"
      (ansible.builtin.systemd 
        (name "icinga-director.service")
        (enabled "False")
        (state "stopped"))
      (when "not icinga_web__director_enabled | bool"))
    (task "Import CA certificates to Icinga Web x509 truststore"
      (ansible.builtin.command "icingacli x509 import --file /etc/ssl/certs/ca-certificates.crt")
      (register "icinga_web__register_import_ca")
      (changed_when "icinga_web__register_import_ca.changed | bool")
      (when "icinga_web__x509_enabled | bool and icinga_web__x509_database_init | bool"))
    (task "Make sure that Ansible local facts directory exists"
      (ansible.builtin.file 
        (path "/etc/ansible/facts.d")
        (state "directory")
        (owner "root")
        (group "root")
        (mode "0755")))
    (task "Save Icinga Web local facts"
      (ansible.builtin.template 
        (src "etc/ansible/facts.d/icinga_web.fact.j2")
        (dest "/etc/ansible/facts.d/icinga_web.fact")
        (owner "root")
        (group "root")
        (mode "0755"))
      (notify (list
          "Refresh host facts"))
      (tags (list
          "meta::facts")))
    (task "Update Ansible facts if they were modified"
      (ansible.builtin.meta "flush_handlers"))
    (task "Register Icinga templates in Icinga Director"
      (ansible.builtin.uri 
        (body_format "json")
        (headers 
          (Accept "application/json"))
        (method "POST")
        (body (jinja "{{ item.data }}"))
        (url (jinja "{{ icinga_web__director_api_url + item.api_endpoint }}"))
        (user (jinja "{{ icinga_web__director_api_user }}"))
        (password (jinja "{{ icinga_web__director_api_password }}"))
        (status_code (list
            "201"
            "422"
            "500"))
        (force_basic_auth "True"))
      (loop (jinja "{{ icinga_web__director_combined_templates | debops.debops.parse_kv_items }}"))
      (loop_control 
        (label (jinja "{{ {\"name\": item.name, \"state\": item.state | d(\"present\")} }}")))
      (register "icinga_web__register_director_templates")
      (when "icinga_web__director_enabled | bool and item.state | d('present') not in ['absent', 'init', 'ignore']")
      (changed_when "icinga_web__register_director_templates.status == 201")
      (no_log (jinja "{{ debops__no_log | d(True) }}"))
      (tags (list
          "role::icinga_web:templates")))))
