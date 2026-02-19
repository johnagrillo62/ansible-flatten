(playbook "ansible-for-devops/includes/provisioning/handlers/handlers.yml"
  (tasks
    (task "restart apache"
      (service "name=apache2 state=restarted"))))
