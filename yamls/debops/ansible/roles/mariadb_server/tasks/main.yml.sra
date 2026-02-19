(playbook "debops/ansible/roles/mariadb_server/tasks/main.yml"
  (tasks
    (task "Import DebOps global handlers"
      (ansible.builtin.import_role 
        (name "global_handlers")))
    (task "Import DebOps secret role"
      (ansible.builtin.import_role 
        (name "secret")))
    (task "Check if database server is installed"
      (ansible.builtin.shell "set -o nounset -o pipefail -o errexit && dpkg-query -W -f='${Version}\\n' 'mariadb-server' 'mysql-server' 'percona-server-server' 'mysql-wsrep-server-5.6' | grep -v '^$'")
      (environment 
        (LC_MESSAGES "C"))
      (args 
        (executable "bash"))
      (register "mariadb_server__register_version")
      (check_mode "False")
      (changed_when "False")
      (failed_when "False"))
    (task "Install database server packages"
      (ansible.builtin.package 
        (name (jinja "{{ q(\"flattened\", (mariadb_server__base_packages
                              + mariadb_server__packages_map[mariadb_server__flavor]
                              + mariadb_server__packages
                              + ([\"automysqlbackup\"]
                                 if mariadb_server__backup | bool
                                 else []))) }}"))
        (state "present"))
      (register "mariadb_server__register_install_status")
      (until "mariadb_server__register_install_status is succeeded"))
    (task "Stop database server on first install"
      (ansible.builtin.service 
        (name "mysql")
        (state "stopped"))
      (when "((mariadb_server__register_version | d() and not mariadb_server__register_version.stdout) and (mariadb_server__register_install_status | d() and mariadb_server__register_install_status is changed))"))
    (task "Add database server user to specified groups"
      (ansible.builtin.user 
        (name "mysql")
        (groups (jinja "{{ mariadb_server__append_groups | join(\",\") | default(omit) }}"))
        (append "True")
        (createhome "False"))
      (when "mariadb_server__pki | bool"))
    (task "Check if MariaDB config directory exists"
      (ansible.builtin.stat 
        (path "/etc/mysql/mariadb.conf.d"))
      (register "mariadb_server__register_confd"))
    (task "Ensure MariaDB data directory exists"
      (ansible.builtin.file 
        (path (jinja "{{ mariadb_server__datadir }}"))
        (state "directory")
        (owner "mysql")
        (group "mysql")
        (mode "0755")))
    (task "Move MariaDB data files to data directory"
      (ansible.builtin.shell "mv " (jinja "{{ mariadb_server__default_datadir }}") "/* " (jinja "{{ mariadb_server__datadir }}"))
      (register "mariadb_server__register_move")
      (changed_when "mariadb_server__register_move.changed | bool")
      (when "((mariadb_server__register_version | d() and not mariadb_server__register_version.stdout) and (mariadb_server__register_install_status | d() and mariadb_server__register_install_status is changed) and (mariadb_server__datadir != mariadb_server__default_datadir))"))
    (task "Configure database client on first install"
      (ansible.builtin.template 
        (src "etc/mysql/conf.d/client.cnf.j2")
        (dest (jinja "{{ mariadb_server__client_cnf_file }}"))
        (owner "root")
        (group "root")
        (mode "0644"))
      (when "(mariadb_server__register_version | d() and not mariadb_server__register_version.stdout)"))
    (task "Configure database server"
      (ansible.builtin.include_tasks "configure_server.yml")
      (tags (list
          "role::mariadb_server:configure")))
    (task "Start database server on first install"
      (ansible.builtin.service 
        (name "mysql")
        (state "started"))
      (when "((mariadb_server__register_version | d() and not mariadb_server__register_version.stdout) and (mariadb_server__register_install_status | d() and mariadb_server__register_install_status is changed))"))
    (task "Secure database server"
      (ansible.builtin.include_tasks "secure_installation.yml")
      (tags (list
          "role::mariadb_server:secure")))
    (task "Make sure that local fact directory exists"
      (ansible.builtin.file 
        (dest "/etc/ansible/facts.d")
        (state "directory")
        (owner "root")
        (group "root")
        (mode "0755")))
    (task "Save MariaDB local facts"
      (ansible.builtin.template 
        (src "etc/ansible/facts.d/mariadb.fact.j2")
        (dest "/etc/ansible/facts.d/mariadb.fact")
        (owner "root")
        (group "root")
        (mode "0644"))
      (notify (list
          "Refresh host facts"))
      (tags (list
          "meta::facts")))
    (task "Re-read local facts if they have been modified"
      (ansible.builtin.meta "flush_handlers"))))
