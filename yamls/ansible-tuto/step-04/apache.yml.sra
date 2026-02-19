(playbook "ansible-tuto/step-04/apache.yml"
    (play
    (hosts "web")
    (tasks
      (task "Installs apache web server"
        (apt 
          (pkg "apache2")
          (state "present")
          (update_cache "true"))))))
