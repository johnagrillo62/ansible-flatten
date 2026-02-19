(playbook "debops/ansible/roles/postgresql_server/tasks/install_postgresql.yml"
  (tasks
    (task "Check if database server is installed"
      (ansible.builtin.shell "set -o nounset -o pipefail -o errexit && dpkg-query -W -f='${Version}\\n' 'postgresql' 'postgresql-" (jinja "{{ postgresql_server__version }}") "' | grep -v '^$'")
      (environment 
        (LC_MESSAGES "C"))
      (args 
        (executable "bash"))
      (register "postgresql_server__register_installed")
      (changed_when "False")
      (check_mode "False")
      (failed_when "False"))
    (task "Install PostgreSQL packages"
      (ansible.builtin.package 
        (name (jinja "{{ q(\"flattened\", (postgresql_server__base_packages
                              + postgresql_server__python_packages
                              + postgresql_server__packages
                              + ([\"autopostgresqlbackup\"]
                                 if (postgresql_server__autopostgresqlbackup | d()) | bool
                                 else []))) }}"))
        (state "present"))
      (register "postgresql_server__register_packages")
      (until "postgresql_server__register_packages is succeeded"))
    (task "Check if default PostgreSQL cluster exists"
      (ansible.builtin.stat 
        (path "/var/lib/postgresql/" (jinja "{{ postgresql_server__version }}") "/main/postmaster.opts"))
      (register "postgresql_server__register_installed_main"))
    (task "Remove default PostgreSQL cluster on first install"
      (ansible.builtin.command "pg_dropcluster --stop " (jinja "{{ postgresql_server__version }}") " main")
      (register "postgresql_server__register_dropcluster")
      (changed_when "postgresql_server__register_dropcluster.changed | bool")
      (when "((postgresql_server__register_installed | d() and not postgresql_server__register_installed.stdout) and (postgresql_server__register_installed_main | d() and postgresql_server__register_installed_main.stat.exists) and (ansible_local is undefined or (ansible_local | d() and ansible_local.postgresql is undefined or (ansible_local | d() and ansible_local.postgresql | d() and ansible_local.postgresql.server != 'localhost'))))"))))
