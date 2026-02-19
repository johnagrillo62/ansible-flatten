(playbook "debops/ansible/roles/mariadb/tasks/manage_contents.yml"
  (tasks
    (task "Drop databases if requested"
      (community.mysql.mysql_db 
        (name (jinja "{{ item.database | d(item.name) }}"))
        (state "absent")
        (login_unix_socket "/run/mysqld/mysqld.sock"))
      (loop (jinja "{{ q(\"flattened\", mariadb__databases + mariadb__dependent_databases + mariadb_databases | d([])) }}"))
      (delegate_to (jinja "{{ mariadb__delegate_to }}"))
      (when "((item.database | d(False) or item.name | d(False)) and (item.state is defined and item.state == 'absent'))"))
    (task "Create databases"
      (community.mysql.mysql_db 
        (name (jinja "{{ item.database | d(item.name) }}"))
        (state "present")
        (encoding (jinja "{{ item.encoding | d(omit) }}"))
        (collation (jinja "{{ item.collation | d(omit) }}"))
        (login_unix_socket "/run/mysqld/mysqld.sock"))
      (loop (jinja "{{ q(\"flattened\", mariadb__databases + mariadb__dependent_databases + mariadb_databases | d([])) }}"))
      (delegate_to (jinja "{{ mariadb__delegate_to }}"))
      (when "((item.database | d(False) or item.name | d(False)) and (item.state is undefined or item.state != 'absent'))")
      (register "mariadb__register_database_status"))
    (task "Copy database source file to remote host"
      (ansible.builtin.copy 
        (src (jinja "{{ item.0.source }}"))
        (dest (jinja "{{ item.0.target }}"))
        (owner "root")
        (group "root")
        (mode "0600"))
      (with_together (list
          (jinja "{{ mariadb__databases
          + lookup(\"flattened\", mariadb__dependent_databases, wantlist=True)
          + mariadb_databases | d([]) }}")
          (jinja "{{ mariadb__register_database_status.results }}")))
      (delegate_to (jinja "{{ mariadb__delegate_to }}"))
      (when "((item.0.database | d(False) or item.0.name | d(False)) and (item.0.state is undefined or item.0.state != 'absent') and (item.0.source | d(False) and item.0.target | d(False)) and (item.0.name == item.1.db and item.1 is changed))"))
    (task "Import source file contents into database"
      (community.mysql.mysql_db 
        (name (jinja "{{ item.0.database | d(item.0.name) }}"))
        (target (jinja "{{ item.0.target }}"))
        (state "import")
        (login_unix_socket "/run/mysqld/mysqld.sock"))
      (with_together (list
          (jinja "{{ mariadb__databases
          + lookup(\"flattened\", mariadb__dependent_databases, wantlist=True)
          + mariadb_databases | d([]) }}")
          (jinja "{{ mariadb__register_database_status.results }}")))
      (delegate_to (jinja "{{ mariadb__delegate_to }}"))
      (when "((item.0.database | d(False) or item.0.name | d(False)) and (item.0.state is undefined or item.0.state != 'absent') and item.0.target | d(False) and (item.0.name == item.1.db and item.1 is changed))"))
    (task "Remove source files"
      (ansible.builtin.file 
        (dest (jinja "{{ item.target }}"))
        (state "absent"))
      (loop (jinja "{{ q(\"flattened\", mariadb__databases + mariadb__dependent_databases + mariadb_databases | d([])) }}"))
      (delegate_to (jinja "{{ mariadb__delegate_to }}"))
      (when "((item.database | d(False) or item.name | d(False)) and (item.state is undefined or item.state != 'absent') and (item.source | d(False) and item.target | d(False)) and (item.target_delete is undefined or item.target_delete))"))
    (task "Drop user accounts if requested"
      (community.mysql.mysql_user 
        (name (jinja "{{ item.user | d(item.name) }}"))
        (host (jinja "{{ item.host | default(mariadb__client) }}"))
        (state "absent")
        (login_unix_socket "/run/mysqld/mysqld.sock"))
      (loop (jinja "{{ q(\"flattened\", mariadb__users + mariadb__dependent_users + mariadb_users | d([])) }}"))
      (delegate_to (jinja "{{ mariadb__delegate_to }}"))
      (when "((item.user | d(False) or item.name | d(False)) and (item.state is defined and item.state == \"absent\"))")
      (no_log (jinja "{{ debops__no_log | d(True) }}")))
    (task "Create user accounts"
      (community.mysql.mysql_user 
        (name (jinja "{{ item.user | d(item.name) }}"))
        (host (jinja "{{ item.host | default(mariadb__client) }}"))
        (state "present")
        (password (jinja "{{ item.password | default(lookup(\"password\",
                  secret + \"/mariadb/\" + mariadb__delegate_to +
                  \"/credentials/\" + item.user | d(item.name) + \"/password \" +
                  \"length=\" + mariadb__password_length)) }}"))
        (login_unix_socket "/run/mysqld/mysqld.sock"))
      (loop (jinja "{{ q(\"flattened\", mariadb__users + mariadb__dependent_users + mariadb_users | d([])) }}"))
      (delegate_to (jinja "{{ mariadb__delegate_to }}"))
      (register "mariadb__register_create_users")
      (when "((item.user | d(False) or item.name | d(False)) and (item.state is undefined or item.state != \"absent\"))")
      (no_log (jinja "{{ debops__no_log | d(True) }}")))
    (task "Grant default privileges to users"
      (community.mysql.mysql_user 
        (name (jinja "{{ item.0.user | d(item.0.name) }}"))
        (host (jinja "{{ item.0.host | default(mariadb__client) }}"))
        (priv (jinja "{{ (item.0.database | d(item.0.name)) + \".*:\" + mariadb__default_privileges_grant }}"))
        (append_privs "True")
        (login_unix_socket "/run/mysqld/mysqld.sock"))
      (with_together (list
          (jinja "{{ mariadb__users + lookup(\"flattened\", mariadb__dependent_users, wantlist=True) + mariadb_users | d([]) }}")
          (jinja "{{ mariadb__register_create_users.results }}")))
      (delegate_to (jinja "{{ mariadb__delegate_to }}"))
      (when "((item.0.user | d(False) or item.0.name | d(False)) and (item.0.state is undefined or item.0.state != \"absent\") and mariadb__default_privileges | d(False) and (item.0.priv_default is undefined or item.0.priv_default))")
      (no_log (jinja "{{ debops__no_log | d(True) }}")))
    (task "Grant auxiliary privileges to users"
      (community.mysql.mysql_user 
        (name (jinja "{{ item.0.user | d(item.0.name) }}"))
        (host (jinja "{{ item.0.host | default(mariadb__client) }}"))
        (priv (jinja "{{ (item.0.database | d(item.0.name)) + \"\\_%.*:\" + mariadb__default_privileges_grant }}"))
        (append_privs "True")
        (login_unix_socket "/run/mysqld/mysqld.sock"))
      (with_together (list
          (jinja "{{ mariadb__users + lookup(\"flattened\", mariadb__dependent_users, wantlist=True) + mariadb_users | d([]) }}")
          (jinja "{{ mariadb__register_create_users.results }}")))
      (delegate_to (jinja "{{ mariadb__delegate_to }}"))
      (when "((item.0.user | d(False) or item.0.name | d(False)) and (item.0.state is undefined or item.0.state != \"absent\") and mariadb__default_privileges_aux | d(False) and (item.0.priv_aux is undefined or item.0.priv_aux))")
      (no_log (jinja "{{ debops__no_log | d(True) }}")))
    (task "Grant custom privileges to users"
      (community.mysql.mysql_user 
        (name (jinja "{{ item.0.user | d(item.0.name) }}"))
        (host (jinja "{{ item.0.host | default(mariadb__client) }}"))
        (priv (jinja "{{ item.0.priv if (item.0.priv is string) else (item.0.priv | join(\"/\")) }}"))
        (append_privs (jinja "{{ item.0.append_privs | default(True) }}"))
        (login_unix_socket "/run/mysqld/mysqld.sock"))
      (with_together (list
          (jinja "{{ mariadb__users + lookup(\"flattened\", mariadb__dependent_users, wantlist=True) + mariadb_users | d([]) }}")
          (jinja "{{ mariadb__register_create_users.results }}")))
      (delegate_to (jinja "{{ mariadb__delegate_to }}"))
      (when "((item.0.user | d(False) or item.0.name | d(False)) and (item.0.state is undefined or item.0.state != \"absent\") and item.0.priv | d(False))")
      (no_log (jinja "{{ debops__no_log | d(True) }}")))
    (task "Make sure required system groups exist"
      (ansible.builtin.group 
        (name (jinja "{{ item.group | d(item.owner) }}"))
        (state "present")
        (system (jinja "{{ item.system | d(True) }}")))
      (loop (jinja "{{ q(\"flattened\", mariadb__users + mariadb__dependent_users + mariadb_users | d([])) }}"))
      (when "((item.user | d(False) or item.name | d(False)) and (item.state is undefined or item.state != \"absent\") and item.owner | d(False) and item.home | d(False))")
      (no_log (jinja "{{ debops__no_log | d(True) }}")))
    (task "Make sure required system accounts exist"
      (ansible.builtin.user 
        (name (jinja "{{ item.owner }}"))
        (group (jinja "{{ item.group | d(item.owner) }}"))
        (home (jinja "{{ item.home }}"))
        (state "present")
        (system (jinja "{{ item.system | d(True) }}")))
      (loop (jinja "{{ q(\"flattened\", mariadb__users + mariadb__dependent_users + mariadb_users | d([])) }}"))
      (when "((item.user | d(False) or item.name | d(False)) and (item.state is undefined or item.state != \"absent\") and item.owner | d(False) and item.home | d(False))")
      (no_log (jinja "{{ debops__no_log | d(True) }}")))
    (task "Remove ~/.my.cnf from owner home if requested"
      (ansible.builtin.file 
        (dest (jinja "{{ \"~\" + item.owner + \"/.my.cnf\" }}"))
        (state "absent"))
      (loop (jinja "{{ q(\"flattened\", mariadb__users + mariadb__dependent_users + mariadb_users | d([])) }}"))
      (when "((item.user | d(False) or item.name | d(False)) and (item.state is defined and item.state == \"absent\") and item.owner | d(False))")
      (no_log (jinja "{{ debops__no_log | d(True) }}")))
    (task "Ensure that directory for custom file path .my.cnf exists"
      (ansible.builtin.file 
        (path (jinja "{{ item.0.creds_path | regex_replace(\"^(.*/).*$\", \"\\\\1\") }}"))
        (state "directory")
        (mode (jinja "{{ item.0.mode | d(\"0755\") }}")))
      (with_together (list
          (jinja "{{ mariadb__users + lookup(\"flattened\", mariadb__dependent_users, wantlist=True) + mariadb_users | d([]) }}")
          (jinja "{{ mariadb__register_create_users.results }}")))
      (when "((item.0.user | d(False) or item.0.name | d(False)) and (item.0.state | d(\"present\") != \"absent\") and item.0.creds_path | d(False) and item.0.owner | d(False))")
      (no_log (jinja "{{ debops__no_log | d(True) }}")))
    (task "Write ~/.my.cnf in owner home directory"
      (ansible.builtin.template 
        (src "home/my.cnf.j2")
        (dest (jinja "{{ item.0.creds_path | d(\"~\" + item.0.owner + \"/.my.cnf\") }}"))
        (owner (jinja "{{ item.0.owner }}"))
        (group (jinja "{{ item.0.group | default(item.0.owner) }}"))
        (mode (jinja "{{ item.0.mode | default(\"0640\") }}")))
      (with_together (list
          (jinja "{{ mariadb__users + lookup(\"flattened\", mariadb__dependent_users, wantlist=True) + mariadb_users | d([]) }}")
          (jinja "{{ mariadb__register_create_users.results }}")))
      (when "((item.0.user | d(False) or item.0.name | d(False)) and (item.0.state is undefined or item.0.state != \"absent\") and item.0.owner | d(False))")
      (no_log (jinja "{{ debops__no_log | d(True) }}")))))
