(playbook "ansible-for-devops/includes/provisioning/tasks/drupal.yml"
  (tasks
    (task "Check out Drupal Core to the Apache docroot."
      (git 
        (repo "https://git.drupal.org/project/drupal.git")
        (version (jinja "{{ drupal_core_version }}"))
        (dest (jinja "{{ drupal_core_path }}")))
      (register "git_checkout"))
    (task "Ensure Drupal codebase is owned by www-data."
      (file 
        (path (jinja "{{ drupal_core_path }}"))
        (owner "www-data")
        (group "www-data")
        (recurse "true"))
      (when "git_checkout.changed | bool"))
    (task "Install Drupal dependencies with Composer."
      (command "/usr/local/bin/composer install chdir=" (jinja "{{ drupal_core_path }}") " creates=" (jinja "{{ drupal_core_path }}") "/vendor/autoload.php
")
      (become_user "www-data"))
    (task "Install Drupal."
      (command "drush si -y --site-name=\"" (jinja "{{ drupal_site_name }}") "\" --account-name=admin --account-pass=admin --db-url=mysql://" (jinja "{{ domain }}") ":1234@localhost/" (jinja "{{ domain }}") " --root=" (jinja "{{ drupal_core_path }}") " creates=" (jinja "{{ drupal_core_path }}") "/sites/default/settings.php
")
      (notify "restart apache")
      (become_user "www-data"))))
