(playbook "ansible-for-devops/includes/provisioning/playbook.yml"
    (play
    (hosts "all")
    (become "yes")
    (vars_files (list
        "vars.yml"))
    (pre_tasks
      (task "Update apt cache if needed."
        (apt "update_cache=yes cache_valid_time=3600")))
    (handlers
      (task
        (import_tasks "handlers/handlers.yml")))
    (tasks
      (task
        (import_tasks "tasks/common.yml"))
      (task
        (import_tasks "tasks/apache.yml"))
      (task
        (import_tasks "tasks/php.yml"))
      (task
        (import_tasks "tasks/mysql.yml"))
      (task
        (import_tasks "tasks/composer.yml"))
      (task
        (import_tasks "tasks/drush.yml"))
      (task
        (import_tasks "tasks/drupal.yml")))))
