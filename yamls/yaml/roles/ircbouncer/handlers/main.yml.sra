(playbook "yaml/roles/ircbouncer/handlers/main.yml"
  (tasks
    (task "restart znc"
      (service "name=znc state=restarted"))))
