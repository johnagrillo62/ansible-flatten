(playbook "yaml/roles/xmpp/tasks/main.yml"
  (tasks
    (task
      (import_tasks "prosody.yml")
      (tags "prosody"))))
