(playbook "ansible-for-devops/includes/provisioning/tasks/apache.yml"
  (tasks
    (task "Enable Apache rewrite module (required for Drupal)."
      (apache2_module "name=rewrite state=present")
      (notify "restart apache"))
    (task "Add Apache virtualhost for Drupal 8."
      (template 
        (src "templates/drupal.test.conf.j2")
        (dest "/etc/apache2/sites-available/" (jinja "{{ domain }}") ".test.conf")
        (owner "root")
        (group "root")
        (mode "0644"))
      (notify "restart apache"))
    (task "Symlink Drupal virtualhost to sites-enabled."
      (file 
        (src "/etc/apache2/sites-available/" (jinja "{{ domain }}") ".test.conf")
        (dest "/etc/apache2/sites-enabled/" (jinja "{{ domain }}") ".test.conf")
        (state "link"))
      (notify "restart apache"))
    (task "Remove default virtualhost file."
      (file 
        (path "/etc/apache2/sites-enabled/000-default.conf")
        (state "absent"))
      (notify "restart apache"))))
