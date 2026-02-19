(playbook "debops/ansible/roles/roundcube/tasks/configure_mysql.yml"
  (tasks
    (task "Create Roundcube MySQL/MariaDB database"
      (community.mysql.mysql_db 
        (name (jinja "{{ roundcube__database_map[roundcube__database].dbname }}"))
        (state "present")
        (login_unix_socket "/run/mysqld/mysqld.sock"))
      (delegate_to (jinja "{{ ansible_local.mariadb.delegate_to }}"))
      (register "roundcube__register_database_status"))
    (task "Import initial database schema"
      (community.mysql.mysql_db 
        (name (jinja "{{ roundcube__database_map[roundcube__database].dbname }}"))
        (state "import")
        (target (jinja "{{ roundcube__database_schema }}"))
        (login_user (jinja "{{ roundcube__database_map[roundcube__database].dbuser }}"))
        (login_password (jinja "{{ roundcube__database_map[roundcube__database].dbpass }}"))
        (login_host (jinja "{{ ansible_local.mariadb.server }}"))
        (login_unix_socket "/run/mysqld/mysqld.sock"))
      (when "(roundcube__register_database_status | d() is defined and roundcube__register_database_status is changed)")
      (no_log (jinja "{{ debops__no_log | d(True) }}")))))
