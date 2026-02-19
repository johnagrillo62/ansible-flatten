(playbook "debops/ansible/roles/icinga_db/tasks/main.yml"
  (tasks
    (task "Import DebOps global handlers"
      (ansible.builtin.import_role 
        (name "global_handlers")))
    (task "Import DebOps secret role"
      (ansible.builtin.import_role 
        (name "secret")))
    (task "Assert that the DB type is valid"
      (ansible.builtin.assert 
        (that (list
            "icinga_db__database_map[icinga_db__type] is defined")))
      (become "False")
      (run_once "True")
      (delegate_to "localhost"))
    (task "Install required packages"
      (ansible.builtin.package 
        (name (jinja "{{ q(\"flattened\", icinga_db__base_packages + icinga_db__packages) }}"))
        (state "present"))
      (register "icinga_db__register_packages")
      (until "icinga_db__register_packages is succeeded")
      (notify (list
          "Check icinga2 configuration and restart"))
      (when "icinga_db__icinga_installed | bool"))
    (task "Create Icinga PostgreSQL tables"
      (community.postgresql.postgresql_db 
        (name (jinja "{{ icinga_db__database }}"))
        (state "restore")
        (target (jinja "{{ icinga_db__schema }}"))
        (login_host (jinja "{{ icinga_db__host }}"))
        (login_user (jinja "{{ icinga_db__user }}"))
        (login_password (jinja "{{ icinga_db__password }}"))
        (ssl_mode (jinja "{{ \"verify-full\" if icinga_db__ssl | d(False) | bool else \"disable\" }}")))
      (no_log (jinja "{{ debops__no_log | d(True) }}"))
      (when "icinga_db__type == 'postgresql' and icinga_db__init | bool"))
    (task "Create Icinga MariaDB tables"
      (community.mysql.mysql_db 
        (name (jinja "{{ icinga_db__database }}"))
        (state "import")
        (target (jinja "{{ icinga_db__schema }}"))
        (login_host (jinja "{{ icinga_db__host }}"))
        (login_user (jinja "{{ icinga_db__user }}"))
        (login_password (jinja "{{ icinga_db__password }}"))
        (check_hostname (jinja "{{ icinga_db__ssl | d(False) | bool }}")))
      (no_log (jinja "{{ debops__no_log | d(True) }}"))
      (when "icinga_db__type == 'mariadb' and icinga_db__init | bool"))
    (task "Add Icinga database configuration file diversion"
      (debops.debops.dpkg_divert 
        (path "/etc/icinga2/features-available/ido-" (jinja "{{ icinga_db__ido }}") ".conf")
        (state "present"))
      (when "icinga_db__icinga_installed | bool"))
    (task "Create Icinga database configuration file"
      (ansible.builtin.template 
        (src "etc/icinga2/features-available/ido-db.conf.j2")
        (dest "/etc/icinga2/features-available/ido-" (jinja "{{ icinga_db__ido }}") ".conf")
        (owner "root")
        (group "nagios")
        (mode "0640"))
      (notify (list
          "Check icinga2 configuration and restart"))
      (when "icinga_db__icinga_installed | bool"))
    (task "Enable Icinga database support"
      (ansible.builtin.file 
        (path "/etc/icinga2/features-enabled/ido-" (jinja "{{ icinga_db__ido }}") ".conf")
        (src "../features-available/ido-" (jinja "{{ icinga_db__ido }}") ".conf")
        (state "link"))
      (notify (list
          "Check icinga2 configuration and restart"))
      (when "icinga_db__icinga_installed | bool"))
    (task "Make sure that Ansible local facts directory exists"
      (ansible.builtin.file 
        (path "/etc/ansible/facts.d")
        (state "directory")
        (owner "root")
        (group "root")
        (mode "0755")))
    (task "Save Icinga database local facts"
      (ansible.builtin.template 
        (src "etc/ansible/facts.d/icinga_db.fact.j2")
        (dest "/etc/ansible/facts.d/icinga_db.fact")
        (owner "root")
        (group "root")
        (mode "0755"))
      (notify (list
          "Refresh host facts"))
      (tags (list
          "meta::facts")))
    (task "Update Ansible facts if they were modified"
      (ansible.builtin.meta "flush_handlers"))))
