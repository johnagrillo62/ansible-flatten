(playbook "ansible-tuto/step-13/roles/apache/handlers/main.yml"
  (tasks
    (task "restart apache"
      (service 
        (name "apache2")
        (state "restarted")))))
