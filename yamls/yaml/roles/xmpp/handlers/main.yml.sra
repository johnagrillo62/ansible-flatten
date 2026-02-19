(playbook "yaml/roles/xmpp/handlers/main.yml"
  (tasks
    (task "restart prosody"
      (service "name=prosody state=restarted"))))
