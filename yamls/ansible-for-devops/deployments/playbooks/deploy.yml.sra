(playbook "ansible-for-devops/deployments/playbooks/deploy.yml"
    (play
    (hosts "all")
    (become "yes")
    (vars_files (list
        "vars.yml"))
    (roles
      "geerlingguy.passenger")
    (tasks
      (task "Ensure demo application is at correct release."
        (git 
          (repo "https://github.com/geerlingguy/demo-rails-app.git")
          (version (jinja "{{ app_version }}"))
          (dest (jinja "{{ app_directory }}"))
          (accept_hostkey "true")
          (force "true"))
        (register "app_updated")
        (notify "restart nginx")
        (become "true")
        (become_user (jinja "{{ app_user }}")))
      (task "Ensure secrets file is present."
        (template 
          (src "templates/secrets.yml.j2")
          (dest (jinja "{{ app_directory }}") "/config/secrets.yml")
          (owner (jinja "{{ app_user }}"))
          (group (jinja "{{ app_user }}"))
          (mode "0664"))
        (notify "restart nginx"))
      (task "Install required dependencies with bundler."
        (command "bundle install --path vendor/bundle chdir=" (jinja "{{ app_directory }}"))
        (when "app_updated.changed == true")
        (notify "restart nginx"))
      (task "Check if database exists."
        (stat "path=" (jinja "{{ app_directory }}") "/db/" (jinja "{{ app_environment.RAILS_ENV }}") ".sqlite3")
        (register "app_db_exists"))
      (task "Create database."
        (command "bundle exec rake db:create chdir=" (jinja "{{ app_directory }}"))
        (when "app_db_exists.stat.exists == false")
        (notify "restart nginx"))
      (task "Perform deployment-related rake tasks."
        (command (jinja "{{ item }}") " chdir=" (jinja "{{ app_directory }}"))
        (with_items (list
            "bundle exec rake db:migrate"
            "bundle exec rake assets:precompile"))
        (environment (jinja "{{ app_environment }}"))
        (when "app_updated.changed == true")
        (notify "restart nginx"))
      (task "Ensure demo application has correct user for files."
        (file 
          (path (jinja "{{ app_directory }}"))
          (state "directory")
          (owner (jinja "{{ app_user }}"))
          (group (jinja "{{ app_user }}"))
          (recurse "yes"))
        (notify "restart nginx")))))
