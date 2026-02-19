(playbook "yaml/roles/tarsnap/tasks/main.yml"
  (tasks
    (task
      (import_tasks "tarsnap.yml")
      (tags "tarsnap"))))
