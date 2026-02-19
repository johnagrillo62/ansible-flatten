(playbook "ansible-tuto/step-13/roles/apache/tasks/apache.yml"
  (tasks
    (task "Installs necessary packages"
      (apt 
        (pkg (list
            "apache2"
            "libapache2-mod-php"
            "git"))
        (state "latest")
        (update_cache "true")))
    (task "Push future default virtual host configuration"
      (copy 
        (src "awesome-app")
        (dest "/etc/apache2/sites-available/awesome-app.conf")
        (mode "0640")))
    (task "Activates our virtualhost"
      (command "a2ensite awesome-app"))
    (task "Check that our config is valid"
      (command "apache2ctl configtest")
      (register "result")
      (ignore_errors "true"))
    (task "Rolling back - Restoring old default virtualhost"
      (command "a2ensite 000-default")
      (when "result is failed"))
    (task "Rolling back - Removing out virtualhost"
      (command "a2dissite awesome-app")
      (when "result is failed"))
    (task "Rolling back - Ending playbook"
      (fail 
        (msg "Configuration file is not valid. Please check that before re-running the playbook."))
      (when "result is failed"))
    (task "Deploy our awesome application"
      (git 
        (repo "https://github.com/leucos/ansible-tuto-demosite.git")
        (dest "/var/www/awesome-app"))
      (tags "deploy"))
    (task "Deactivates the default virtualhost"
      (command "a2dissite 000-default"))
    (task "Deactivates the default ssl virtualhost"
      (command "a2dissite default-ssl")
      (notify (list
          "restart apache")))))
