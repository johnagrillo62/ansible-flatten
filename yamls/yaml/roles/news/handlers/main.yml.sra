(playbook "yaml/roles/news/handlers/main.yml"
  (tasks
    (task "restart apache"
      (service "name=apache2 state=restarted"))))
