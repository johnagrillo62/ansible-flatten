(playbook "debops/ansible/roles/postgresql_server/tasks/manage_clusters.yml"
  (tasks
    (task "Check if shared memory support is available"
      (ansible.builtin.shell "set -o nounset -o pipefail -o errexit && mount | grep /dev/shm || true")
      (args 
        (executable "bash"))
      (register "postgresql_server__register_shm")
      (changed_when "False")
      (check_mode "False")
      (tags (list
          "role::postgresql_server:config")))
    (task "Create PostgreSQL clusters"
      (ansible.builtin.command "pg_createcluster --user=" (jinja "{{ item.user | d(postgresql_server__user) }}") " --group=" (jinja "{{ item.group | d(postgresql_server__group) }}") " --locale=" (jinja "{{ item.locale | d(postgresql_server__locale) }}") " --start-conf=" (jinja "{{ item.start_conf | d(postgresql_server__start_conf) }}") " --port=" (jinja "{{ item.port }}") " " (jinja "{{ item.version | d(postgresql_server__version) }}") " " (jinja "{{ item.name }}"))
      (environment 
        (LANG (jinja "{{ item.locale | d(postgresql_server__locale) }}"))
        (LC_ALL (jinja "{{ item.locale | d(postgresql_server__locale) }}")))
      (args 
        (creates "/etc/postgresql/" (jinja "{{ item.version | d(postgresql_server__version) }}") "/" (jinja "{{ item.name }}") "/postgresql.conf"))
      (register "postgresql_server__register_createcluster")
      (loop (jinja "{{ q(\"flattened\", postgresql_server__clusters) }}"))
      (when "item.name | d() and item.port | d()"))
    (task "Remove data directory for PostgreSQL replication standby clusters"
      (ansible.builtin.file 
        (path (jinja "{{ item.item.data_directory | d(postgresql_server__data_directory + \"/\"
                                           + (item.item.version | d(postgresql_server__version))
                                           + \"/\" + item.item.name) }}"))
        (state "absent"))
      (when (list
          "item.item.standby is defined"
          "item is changed"
          "item is success"))
      (with_items (jinja "{{ postgresql_server__register_createcluster.results }}"))
      (loop_control 
        (label (jinja "{{ item.item }}"))))
    (task "Synchronize data for PostgreSQL replication standby clusters"
      (ansible.builtin.command "pg_basebackup --pgdata=" (jinja "{{ item.item.data_directory | d(postgresql_server__data_directory + \"/\"
                                         + (item.item.version | d(postgresql_server__version))
                                         + \"/\" + item.item.name) }}") "
--dbname=\"" (jinja "{{ item.item.standby.conninfo }}") "\" --write-recovery-conf " (jinja "{% if item.item.standby.slot_name is defined %}") " --slot=" (jinja "{{ item.item.standby.slot_name }}") " --create-slot " (jinja "{% endif %}"))
      (environment 
        (LANG (jinja "{{ item.item.locale | d(postgresql_server__locale) }}"))
        (LC_ALL (jinja "{{ item.item.locale | d(postgresql_server__locale) }}")))
      (become "True")
      (become_user (jinja "{{ item.user | d(postgresql_server__user) }}"))
      (when (list
          "item.item.standby is defined"
          "item is changed"
          "item is success"))
      (with_items (jinja "{{ postgresql_server__register_createcluster.results }}"))
      (loop_control 
        (label (jinja "{{ item.item }}")))
      (register "postgresql_server__register_basebackup")
      (changed_when "postgresql_server__register_basebackup.changed | bool"))
    (task "Log directory path"
      (ansible.builtin.file 
        (name (jinja "{{ item.log_directory }}"))
        (mode "0750")
        (owner (jinja "{{ item.user | d(postgresql_server__user) }}"))
        (group (jinja "{{ item.group | d(postgresql_server__group) }}"))
        (state "directory")
        (recurse "yes"))
      (loop (jinja "{{ q(\"flattened\", postgresql_server__clusters) }}"))
      (when "item.log_directory | d() and item.log_directory is abs")
      (tags (list
          "role::postgresql_server:config")))
    (task "Ensure that conf.d directories exist"
      (ansible.builtin.file 
        (path "/etc/postgresql/" (jinja "{{ item.version | d(postgresql_server__version) }}") "/" (jinja "{{ item.name }}") "/conf.d")
        (state "directory")
        (owner (jinja "{{ item.user | d(postgresql_server__user) }}"))
        (group (jinja "{{ item.group | d(postgresql_server__group) }}"))
        (mode "0755"))
      (loop (jinja "{{ q(\"flattened\", postgresql_server__clusters) }}"))
      (when "item.name | d()")
      (tags (list
          "role::postgresql_server:config")))
    (task "Configure PostgreSQL clusters"
      (ansible.builtin.template 
        (src "etc/postgresql/postgresql.conf.j2")
        (dest "/etc/postgresql/" (jinja "{{ item.version | d(postgresql_server__version) }}") "/" (jinja "{{ item.name }}") "/postgresql.conf")
        (owner (jinja "{{ item.user | d(postgresql_server__user) }}"))
        (group (jinja "{{ item.group | d(postgresql_server__group) }}"))
        (mode "0644"))
      (loop (jinja "{{ q(\"flattened\", postgresql_server__clusters) }}"))
      (when "item.name | d()")
      (register "postgresql_server__register_config")
      (tags (list
          "role::postgresql_server:config")))
    (task "Configure PostgreSQL cluster environment"
      (ansible.builtin.template 
        (src "etc/postgresql/environment.j2")
        (dest "/etc/postgresql/" (jinja "{{ item.version | d(postgresql_server__version) }}") "/" (jinja "{{ item.name }}") "/environment")
        (owner (jinja "{{ item.user | d(postgresql_server__user) }}"))
        (group (jinja "{{ item.group | d(postgresql_server__group) }}"))
        (mode "0644"))
      (loop (jinja "{{ q(\"flattened\", postgresql_server__clusters) }}"))
      (when "item.name | d()")
      (register "postgresql_server__register_config_environment")
      (tags (list
          "role::postgresql_server:config")))
    (task "Configure PostgreSQL user identification"
      (ansible.builtin.template 
        (src "etc/postgresql/pg_ident.conf.j2")
        (dest "/etc/postgresql/" (jinja "{{ item.version | d(postgresql_server__version) }}") "/" (jinja "{{ item.name }}") "/pg_ident.conf")
        (owner (jinja "{{ item.user | d(postgresql_server__user) }}"))
        (group (jinja "{{ item.group | d(postgresql_server__group) }}"))
        (mode "0640"))
      (loop (jinja "{{ q(\"flattened\", postgresql_server__clusters) }}"))
      (when "item.name | d()")
      (register "postgresql_server__register_config_ident")
      (tags (list
          "role::postgresql_server:config")))
    (task "Configure PostgreSQL cluster host authentication"
      (ansible.builtin.template 
        (src "etc/postgresql/pg_hba.conf.j2")
        (dest "/etc/postgresql/" (jinja "{{ item.version | d(postgresql_server__version) }}") "/" (jinja "{{ item.name }}") "/pg_hba.conf")
        (owner (jinja "{{ item.user | d(postgresql_server__user) }}"))
        (group (jinja "{{ item.group | d(postgresql_server__group) }}"))
        (mode "0640"))
      (loop (jinja "{{ q(\"flattened\", postgresql_server__clusters) }}"))
      (when "item.name | d()")
      (register "postgresql_server__register_config_hba")
      (tags (list
          "role::postgresql_server:config")))
    (task "Configure PostgreSQL cluster trusted local roles"
      (ansible.builtin.template 
        (src "etc/postgresql/trusted.j2")
        (dest "/etc/postgresql/" (jinja "{{ (item.version | d(postgresql_server__version)) + \"/\" + item.name + \"/trusted\" }}"))
        (owner (jinja "{{ item.user | d(postgresql_server__user) }}"))
        (group (jinja "{{ item.group | d(postgresql_server__group) }}"))
        (mode "0640"))
      (loop (jinja "{{ q(\"flattened\", postgresql_server__clusters) }}"))
      (when "item.name | d()")
      (register "postgresql_server__register_trusted")
      (tags (list
          "role::postgresql_server:config")))
    (task "Configure PostgreSQL cluster start options"
      (ansible.builtin.template 
        (src "etc/postgresql/start.conf.j2")
        (dest "/etc/postgresql/" (jinja "{{ item.version | d(postgresql_server__version) }}") "/" (jinja "{{ item.name }}") "/start.conf")
        (owner (jinja "{{ item.user | d(postgresql_server__user) }}"))
        (group (jinja "{{ item.group | d(postgresql_server__group) }}"))
        (mode "0644"))
      (loop (jinja "{{ q(\"flattened\", postgresql_server__clusters) }}"))
      (when "item.name | d()")
      (register "postgresql_server__register_config_start")
      (tags (list
          "role::postgresql_server:config")))
    (task "Symlink SSL root certificate"
      (ansible.builtin.file 
        (src (jinja "{{ item.pki_path | d(postgresql_server__pki_path) + \"/\" + item.pki_realm | d(postgresql_server__pki_realm)
             + \"/\" + item.pki_ca | d(postgresql_server__pki_ca) }}"))
        (dest (jinja "{{ (item.data_directory | d(postgresql_server__data_directory
                                       + (item.version | d(postgresql_server__version)) + \"/\" + item.name))
              + \"/root.crt\" }}"))
        (state "link")
        (mode "0644"))
      (loop (jinja "{{ q(\"flattened\", postgresql_server__clusters) }}"))
      (when "((postgresql_server__pki | d() and postgresql_server__pki | bool) and (item.name | d()) and ((item.version | d() and item.version == '9.1') or (postgresql_server__version | d() and postgresql_server__version == '9.1')))"))
    (task "Symlink SSL certificate"
      (ansible.builtin.file 
        (src (jinja "{{ item.pki_path | d(postgresql_server__pki_path) + \"/\" + item.pki_realm | d(postgresql_server__pki_realm)
             + \"/\" + item.pki_crt | d(postgresql_server__pki_crt) }}"))
        (dest (jinja "{{ (item.data_directory | d(postgresql_server__data_directory
                                       + (item.version | d(postgresql_server__version)) + \"/\" + item.name))
              + \"/server.crt\" }}"))
        (state "link")
        (mode "0644"))
      (loop (jinja "{{ q(\"flattened\", postgresql_server__clusters) }}"))
      (when "((postgresql_server__pki | d() and postgresql_server__pki | bool) and (item.name | d()) and ((item.version | d() and item.version == '9.1') or (postgresql_server__version | d() and postgresql_server__version == '9.1')))"))
    (task "Symlink SSL key"
      (ansible.builtin.file 
        (src (jinja "{{ item.pki_path | d(postgresql_server__pki_path) + \"/\" + item.pki_realm | d(postgresql_server__pki_realm)
             + \"/\" + item.pki_key | d(postgresql_server__pki_key) }}"))
        (dest (jinja "{{ (item.data_directory | d(postgresql_server__data_directory
                                       + (item.version | d(postgresql_server__version)) + \"/\" + item.name))
              + \"/server.key\" }}"))
        (state "link")
        (mode "0640"))
      (loop (jinja "{{ q(\"flattened\", postgresql_server__clusters) }}"))
      (when "((postgresql_server__pki | d() and postgresql_server__pki | bool) and (item.name | d()) and ((item.version | d() and item.version == '9.1') or (postgresql_server__version | d() and postgresql_server__version == '9.1')))"))
    (task "Start PostgreSQL clusters when not started"
      (ansible.builtin.command "pg_ctlcluster " (jinja "{{ item.version | d(postgresql_server__version) }}") " " (jinja "{{ item.name }}") " start")
      (args 
        (creates (jinja "{{ item.external_pid_file | d(\"/var/run/postgresql/\" + (item.version | d(postgresql_server__version))
                                            + \"-\" + item.name + \".pid\") }}")))
      (loop (jinja "{{ q(\"flattened\", postgresql_server__clusters) }}"))
      (when "(ansible_service_mgr != 'systemd' and ((item.name | d()) and (item.start_conf is undefined or item.start_conf == 'auto')))"))
    (task "Start PostgreSQL clusters when not started (systemd)"
      (ansible.builtin.service 
        (name "postgresql@" (jinja "{{ item.version | d(postgresql_server__version) }}") "-" (jinja "{{ item.name }}") ".service")
        (state "started"))
      (loop (jinja "{{ q(\"flattened\", postgresql_server__clusters) }}"))
      (when "(ansible_service_mgr == 'systemd' and ((item.name | d()) and (item.start_conf is undefined or item.start_conf == 'auto')))"))
    (task "Reload PostgreSQL clusters when needed"
      (ansible.builtin.command "pg_ctlcluster " (jinja "{{ item.item.version | d(postgresql_server__version) }}") " " (jinja "{{ item.item.name }}") " reload")
      (loop (jinja "{{ q(\"flattened\", postgresql_server__register_config.results
                           + postgresql_server__register_config_hba.results
                           + postgresql_server__register_config_ident.results
                           + postgresql_server__register_trusted.results) }}"))
      (register "postgresql_server__register_pg_cluster_reload")
      (changed_when "postgresql_server__register_pg_cluster_reload.changed | bool")
      (when "(ansible_service_mgr != 'systemd' and ((item is changed and (item.item.start_conf is undefined or item.item.start_conf == 'auto'))))")
      (tags (list
          "role::postgresql_server:config")))
    (task "Reload PostgreSQL clusters when needed (systemd)"
      (ansible.builtin.service 
        (name "postgresql@" (jinja "{{ item.item.version | d(postgresql_server__version) }}") "-" (jinja "{{ item.item.name }}") ".service")
        (state "reloaded"))
      (loop (jinja "{{ q(\"flattened\", postgresql_server__register_config.results
                           + postgresql_server__register_config_hba.results
                           + postgresql_server__register_config_ident.results
                           + postgresql_server__register_trusted.results) }}"))
      (when "(ansible_service_mgr == 'systemd' and ((item is changed and (item.item.start_conf is undefined or item.item.start_conf == 'auto'))))")
      (tags (list
          "role::postgresql_server:config")))))
