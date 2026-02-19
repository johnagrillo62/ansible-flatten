(playbook "yaml/roles/news/tasks/main.yml"
  (tasks
    (task
      (import_tasks "selfoss.yml")
      (tags "selfoss"))))
