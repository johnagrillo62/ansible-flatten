(playbook "debops/ansible/roles/postgresql_server/tasks/main.yml"
  (tasks
    (task "Import DebOps global handlers"
      (ansible.builtin.import_role 
        (name "global_handlers")))
    (task "Import DebOps secret role"
      (ansible.builtin.import_role 
        (name "secret")))
    (task "Get default PostgreSQL version"
      (ansible.builtin.shell "set -o nounset -o pipefail -o errexit && apt-cache policy postgresql | grep -E '^\\s+Candidate:\\s+' | awk '{print $2}' | cut -d+ -f1")
      (environment 
        (LC_ALL "C"))
      (args 
        (executable "bash"))
      (register "postgresql_server__register_version")
      (changed_when "False")
      (check_mode "False")
      (tags (list
          "role::postgresql_server:packages"
          "role::postgresql_server:config"
          "role::postgresql_server:auto_backup")))
    (task "Set default PostgreSQL version variable"
      (ansible.builtin.set_fact 
        (postgresql_server__version (jinja "{{ (ansible_local.postgresql.version
                                     if (ansible_local.postgresql.version | d())
                                     else (postgresql_server__preferred_version
                                           if postgresql_server__preferred_version | d()
                                           else postgresql_server__register_version.stdout)) }}")))
      (tags (list
          "role::postgresql_server:packages"
          "role::postgresql_server:config"
          "role::postgresql_server:auto_backup")))
    (task "Install PostgreSQL database service"
      (ansible.builtin.include_tasks "install_postgresql.yml")
      (tags (list
          "role::postgresql_server:packages")))
    (task "Configure custom PostgreSQL data directory"
      (ansible.builtin.lineinfile 
        (path "/etc/postgresql-common/createcluster.conf")
        (regexp "^data_directory\\s+=")
        (line "data_directory = '" (jinja "{{ postgresql_server__data_directory }}") "/%v/%c'")
        (mode "0644"))
      (when "postgresql_server__data_directory != '/var/lib/postgresql'"))
    (task "Make sure that custom PostgreSQL data directory exists"
      (ansible.builtin.file 
        (path (jinja "{{ postgresql_server__data_directory }}"))
        (state "directory")
        (owner (jinja "{{ postgresql_server__user }}"))
        (group (jinja "{{ postgresql_server__group }}"))
        (mode "0750"))
      (when "postgresql_server__data_directory != '/var/lib/postgresql'"))
    (task "Make sure that custom PostgreSQL Log directory exists"
      (ansible.builtin.file 
        (path (jinja "{{ postgresql_server__log_directory }}"))
        (state "directory")
        (owner (jinja "{{ \"postgres\" if (postgresql_server__pgbadger_logs | bool) else \"root\" }}"))
        (group (jinja "{{ \"adm\" if (postgresql_server__pgbadger_logs | bool) else \"postgres\" }}"))
        (mode (jinja "{{ \"u=rwx,g=rxs,o=rxt\" if (postgresql_server__pgbadger_logs | bool) else \"u=rwx,g=rwx,o=rxt\" }}")))
      (when "postgresql_server__log_directory"))
    (task "Count number of currently configured clusters"
      (ansible.builtin.set_fact 
        (postgresql_server__fact_cluster_count (jinja "{{ (postgresql_server__clusters | length | int) * 1 }}")))
      (tags (list
          "role::postgresql_server:config")))
    (task "Get current maximum shared memory value"
      (ansible.builtin.command "cat /proc/sys/kernel/shmmax")
      (register "postgresql_server__register_sysctl_shmmax")
      (changed_when "False")
      (check_mode "False")
      (tags (list
          "role::postgresql_server:config")))
    (task "Manage PostgreSQL clusters"
      (ansible.builtin.include_tasks "manage_clusters.yml"))
    (task "Secure PostgreSQL installation"
      (ansible.builtin.include_tasks "secure_installation.yml"))
    (task "Manage AutoPostgreSQLBackup script"
      (ansible.builtin.include_tasks "manage_autopostgresqlbackup.yml")
      (when "postgresql_server__autopostgresqlbackup | bool")
      (tags (list
          "role::postgresql_server:auto_backup")))
    (task "Make sure that Ansible local fact directory exists"
      (ansible.builtin.file 
        (path "/etc/ansible/facts.d")
        (state "directory")
        (owner "root")
        (group "root")
        (mode "0755")))
    (task "Save PostgreSQL local facts"
      (ansible.builtin.template 
        (src "etc/ansible/facts.d/postgresql.fact.j2")
        (dest "/etc/ansible/facts.d/postgresql.fact")
        (owner "root")
        (group "root")
        (mode "0644"))
      (notify (list
          "Refresh host facts"))
      (tags (list
          "meta::facts"
          "role::postgresql_server:config")))
    (task "Re-read local facts if they have been modified"
      (ansible.builtin.meta "flush_handlers"))))
