(playbook "ansible-tuto/step-06/apache.yml"
    (play
    (hosts "web")
    (tasks
      (task "Installs apache web server"
        (apt 
          (pkg "apache2")
          (state "present")
          (update_cache "true")))
      (task "Push future default virtual host configuration"
        (copy 
          (src "files/awesome-app")
          (dest "/etc/apache2/sites-available/awesome-app.conf")
          (mode "0640")))
      (task "Activates our virtualhost"
        (command "a2ensite awesome-app"))
      (task "Check that our config is valid"
        (command "apache2ctl configtest"))
      (task "Deactivates the default virtualhost"
        (command "a2dissite 000-default"))
      (task "Deactivates the default ssl virtualhost"
        (command "a2dissite default-ssl")
        (notify (list
            "restart apache"))))
    (handlers
      (task "restart apache"
        (service 
          (name "apache2")
          (state "restarted"))))))
