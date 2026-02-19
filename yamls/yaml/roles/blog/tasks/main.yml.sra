(playbook "yaml/roles/blog/tasks/main.yml"
  (tasks
    (task
      (import_tasks "blog.yml")
      (tags "blog"))))
