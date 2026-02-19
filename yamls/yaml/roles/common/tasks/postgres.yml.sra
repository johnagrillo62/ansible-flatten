(playbook "yaml/roles/common/tasks/postgres.yml"
  (tasks
    (task "Install Postgres"
      (apt "pkg=" (jinja "{{ item }}") " state=present")
      (with_items (list
          "postgresql"
          "python-psycopg2"))
      (tags (list
          "dependencies")))
    (task "Set password for PostgreSQL admin user"
      (postgresql_user "name=" (jinja "{{ db_admin_username }}") " password=" (jinja "{{ db_admin_password }}") " encrypted=yes")
      (become "true")
      (become_user "postgres"))))
