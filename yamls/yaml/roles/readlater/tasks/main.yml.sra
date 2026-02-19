(playbook "yaml/roles/readlater/tasks/main.yml"
  (tasks
    (task
      (import_tasks "wallabag.yml")
      (tags "wallabag"))))
