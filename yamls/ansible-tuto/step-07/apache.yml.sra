(playbook "ansible-tuto/step-07/apache.yml"
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
        (command "apache2ctl configtest")
        (register "result")
        (ignore_errors "true"))
      (task "Rolling back - Restoring old default virtualhost"
        (command "a2ensite 000-default")
        (when "result is failed"))
      (task "Rolling back - Removing our virtualhost"
        (command "a2dissite awesome-app")
        (when "result is failed"))
      (task "Rolling back - Ending playbook"
        (fail 
          (msg "Configuration file is not valid. Please check that before re-running the playbook."))
        (when "result is failed"))
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
