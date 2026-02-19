(playbook "yaml/roles/readlater/handlers/main.yml"
  (tasks
    (task "import wallabag sql"
      (command "psql -h localhost -d " (jinja "{{ wallabag_db_database }}") " -U " (jinja "{{ wallabag_db_username }}") " -f /var/www/wallabag/install/postgres.sql --set ON_ERROR_STOP=1")
      (environment 
        (PGPASSWORD (jinja "{{ wallabag_db_password }}")))
      (notify "remove install folder"))
    (task "remove install folder"
      (file "path=/var/www/wallabag/install state=absent"))))
