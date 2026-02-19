(playbook "yaml/roles/ircbouncer/tasks/main.yml"
  (tasks
    (task
      (import_tasks "znc.yml")
      (tags "znc"))))
