(playbook "debops/ansible/roles/pdns/tasks/init_postgresql.yml"
  (tasks
    (task "Create PostgreSQL database"
      (community.postgresql.postgresql_db 
        (name (jinja "{{ pdns__postgresql_database }}"))
        (owner (jinja "{{ pdns__postgresql_role }}"))
        (state "present"))
      (delegate_to (jinja "{{ pdns__postgresql_delegate_to }}"))
      (register "pdns__register_postgresql_status"))
    (task "Import initial database schema"
      (community.postgresql.postgresql_db 
        (login_user (jinja "{{ pdns__postgresql_role }}"))
        (login_password (jinja "{{ pdns__postgresql_password }}"))
        (name (jinja "{{ pdns__postgresql_database }}"))
        (target (jinja "{{ pdns__postgresql_schema }}"))
        (state "restore"))
      (when "pdns__register_postgresql_status is changed"))))
