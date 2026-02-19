(playbook "debops/ansible/roles/mariadb/tasks/main.yml"
  (tasks
    (task "Import DebOps global handlers"
      (ansible.builtin.import_role 
        (name "global_handlers")))
    (task "Import DebOps secret role"
      (ansible.builtin.import_role 
        (name "secret")))
    (task "Check if database server is installed"
      (ansible.builtin.shell "set -o nounset -o pipefail -o errexit && dpkg-query -W -f='${Version}\\n' 'mariadb-server' 'mysql-server' 'percona-server-server*' | grep -v '^$'")
      (environment 
        (LC_MESSAGES "C"))
      (args 
        (executable "bash"))
      (register "mariadb__register_version")
      (changed_when "False")
      (failed_when "False")
      (check_mode "False"))
    (task "Check if local database port is open"
      (ansible.builtin.command "nc -z localhost " (jinja "{{ mariadb__port }}"))
      (register "mariadb__register_tunnel")
      (when "not mariadb__register_version.stdout")
      (failed_when "False")
      (changed_when "False"))
    (task "Override delegation if tunnel is detected"
      (ansible.builtin.set_fact 
        (mariadb__delegate_to (jinja "{{ mariadb__server | d(\"undefined\") }}")))
      (when "(not mariadb__register_version.stdout | d(False) and (mariadb__register_tunnel | d() and mariadb__register_tunnel.rc == 0))"))
    (task "Override configuration if local server is detected"
      (ansible.builtin.set_fact 
        (mariadb__server "localhost")
        (mariadb__client "localhost"))
      (when "(mariadb__register_version.stdout | d(False) or (mariadb__register_tunnel | d() and mariadb__register_tunnel.rc == 0))"))
    (task "Install database client packages"
      (ansible.builtin.package 
        (name (jinja "{{ q(\"flattened\", (mariadb__base_packages
                              + mariadb__packages_map[mariadb__flavor]
                              + mariadb__packages)) }}"))
        (state "present"))
      (register "mariadb__register_packages")
      (until "mariadb__register_packages is succeeded"))
    (task "Check if MariaDB config directory exists"
      (ansible.builtin.stat 
        (path "/etc/mysql/mariadb.conf.d"))
      (register "mariadb__register_confd"))
    (task "Configure database client defaults"
      (ansible.builtin.template 
        (src "etc/mysql/conf.d/client.cnf.j2")
        (dest (jinja "{{ mariadb__client_cnf_file }}"))
        (owner "root")
        (group "root")
        (mode "0644"))
      (when "mariadb__server | d(False)"))
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
      (ansible.builtin.meta "flush_handlers"))
    (task "Manage database contents"
      (ansible.builtin.include_tasks "manage_contents.yml")
      (when "(mariadb__server | d(False) and mariadb__delegate_to)")
      (tags (list
          "role::mariadb:contents")))))
