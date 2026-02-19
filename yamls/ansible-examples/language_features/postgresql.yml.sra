(playbook "ansible-examples/language_features/postgresql.yml"
    (play
    (hosts "webservers")
    (become "yes")
    (gather_facts "no")
    (tasks
      (task "ensure apt cache is up to date"
        (apt "update_cache=yes"))
      (task "ensure packages are installed"
        (apt "name=" (jinja "{{item}}"))
        (with_items (list
            "postgresql"
            "libpq-dev"
            "python-psycopg2")))))
    (play
    (hosts "webservers")
    (become "yes")
    (become_user "postgres")
    (gather_facts "no")
    (vars
      (dbname "myapp")
      (dbuser "django")
      (dbpassword "mysupersecretpassword"))
    (tasks
      (task "ensure database is created"
        (postgresql_db "name=" (jinja "{{dbname}}")))
      (task "ensure user has access to database"
        (postgresql_user "db=" (jinja "{{dbname}}") " name=" (jinja "{{dbuser}}") " password=" (jinja "{{dbpassword}}") " priv=ALL"))
      (task "ensure user does not have unnecessary privilege"
        (postgresql_user "name=" (jinja "{{dbuser}}") " role_attr_flags=NOSUPERUSER,NOCREATEDB"))
      (task "ensure no other user can access the database"
        (postgresql_privs "db=" (jinja "{{dbname}}") " role=PUBLIC type=database priv=ALL state=absent")))))
