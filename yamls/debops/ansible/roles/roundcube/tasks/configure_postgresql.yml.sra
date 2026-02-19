(playbook "debops/ansible/roles/roundcube/tasks/configure_postgresql.yml"
  (tasks
    (task "Create Roundcube PostgreSQL database"
      (community.postgresql.postgresql_db 
        (name (jinja "{{ roundcube__database_map[roundcube__database].dbname }}"))
        (owner (jinja "{{ roundcube__database_map[roundcube__database].dbuser }}"))
        (state "present"))
      (delegate_to (jinja "{{ ansible_local.postgresql.delegate_to }}"))
      (register "roundcube__register_postgresql_status"))
    (task "Import initial database schema"
      (community.postgresql.postgresql_db 
        (name (jinja "{{ roundcube__database_map[roundcube__database].dbname }}"))
        (state "restore")
        (target (jinja "{{ roundcube__database_schema }}"))
        (login_user (jinja "{{ roundcube__database_map[roundcube__database].dbuser }}"))
        (login_password (jinja "{{ roundcube__database_map[roundcube__database].dbpass }}"))
        (login_host (jinja "{{ roundcube__database_map[roundcube__database].dbhost }}")))
      (when "(roundcube__register_postgresql_status | d() is defined and roundcube__register_postgresql_status is changed)")
      (no_log (jinja "{{ debops__no_log | d(True) }}")))))
