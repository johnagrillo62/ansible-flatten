(playbook "ansible-for-devops/includes/provisioning/tasks/drush.yml"
  (tasks
    (task "Check out drush 8.x branch."
      (git 
        (repo "https://github.com/drush-ops/drush.git")
        (version "8.x")
        (dest "/opt/drush")))
    (task "Install Drush dependencies with Composer."
      (command "/usr/local/bin/composer install chdir=/opt/drush creates=/opt/drush/vendor/autoload.php
"))
    (task "Create drush bin symlink."
      (file 
        (src "/opt/drush/drush")
        (dest "/usr/local/bin/drush")
        (state "link")))))
