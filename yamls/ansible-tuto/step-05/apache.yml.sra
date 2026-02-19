(playbook "ansible-tuto/step-05/apache.yml"
    (play
    (hosts "web")
    (tasks
      (task "Installs apache web server"
        (apt 
          (pkg "apache2")
          (state "present")
          (update_cache "true")))
      (task "Push default virtual host configuration"
        (copy 
          (src "files/awesome-app")
          (dest "/etc/apache2/sites-available/awesome-app.conf")
          (mode "0640")))
      (task "Activates our virtualhost"
        (file 
          (src "/etc/apache2/sites-available/awesome-app.conf")
          (dest "/etc/apache2/sites-enabled/awesome-app.conf")
          (state "link"))
        (notify (list
            "restart apache")))
      (task "Disable the default virtualhost"
        (file 
          (dest "/etc/apache2/sites-enabled/000-default.conf")
          (state "absent"))
        (notify (list
            "restart apache")))
      (task "Disable the default ssl virtualhost"
        (file 
          (dest "/etc/apache2/sites-enabled/default-ssl.conf")
          (state "absent"))
        (notify (list
            "restart apache"))))
    (handlers
      (task "restart apache"
        (service 
          (name "apache2")
          (state "restarted"))))))
