(playbook "ansible-galaxy/tasks/database.yml"
  (tasks
    (task "Manage Galaxy database"
      (block (list
          
          (name "Get current Galaxy DB version")
          (command (jinja "{{ galaxy_venv_dir }}") "/bin/python " (jinja "{{ galaxy_server_dir }}") "/scripts/manage_db.py -c " (jinja "{{ galaxy_config_file }}") " db_version")
          (args 
            (chdir (jinja "{{ galaxy_server_dir }}")))
          (register "current_db_version")
          (changed_when "no")
          (failed_when (list
              "current_db_version.rc != 0"
              "'migrate.exceptions.DatabaseNotControlledError' not in current_db_version.stderr"
              "'galaxy.model.migrations.NoVersionTableError' not in current_db_version.stderr"
              "'galaxy.model.migrations.exceptions.NoVersionTableError' not in current_db_version.stderr"))
          (when "not ansible_check_mode")
          
          (name "Get maximum Galaxy DB version")
          (command (jinja "{{ galaxy_venv_dir }}") "/bin/python " (jinja "{{ galaxy_server_dir }}") "/scripts/manage_db.py -c " (jinja "{{ galaxy_config_file }}") " version")
          (args 
            (chdir (jinja "{{ galaxy_server_dir }}")))
          (register "max_db_version")
          (changed_when "no")
          (when "not ansible_check_mode")
          
          (name "Report current and max Galaxy database")
          (debug 
            (msg "Current database version is " (jinja "{{ current_db_version.stdout }}") " and the maximum version is " (jinja "{{ max_db_version.stdout }}") "."))
          (changed_when "True")
          (when (list
              "not ansible_check_mode"
              "current_db_version.stdout != max_db_version.stdout"
              "'migrate.exceptions.DatabaseNotControlledError' not in current_db_version.stderr"
              "'galaxy.model.migrations.NoVersionTableError' not in current_db_version.stderr"
              "'galaxy.model.migrations.exceptions.NoVersionTableError' not in current_db_version.stderr"))
          
          (name "Upgrade Galaxy DB")
          (command (jinja "{{ galaxy_venv_dir }}") "/bin/python " (jinja "{{ galaxy_server_dir }}") "/scripts/manage_db.py -c " (jinja "{{ galaxy_config_file }}") " upgrade")
          (args 
            (chdir (jinja "{{ galaxy_server_dir }}")))
          (when (list
              "not ansible_check_mode"
              "current_db_version.stdout != max_db_version.stdout"
              "'migrate.exceptions.DatabaseNotControlledError' not in current_db_version.stderr"
              "'galaxy.model.migrations.NoVersionTableError' not in current_db_version.stderr"
              "'galaxy.model.migrations.exceptions.NoVersionTableError' not in current_db_version.stderr"))))
      (remote_user (jinja "{{ galaxy_remote_users.galaxy | default(__galaxy_remote_user) }}"))
      (become (jinja "{{ true if galaxy_become_users.galaxy is defined else __galaxy_become }}"))
      (become_user (jinja "{{ galaxy_become_users.galaxy | default(__galaxy_become_user) }}")))))
