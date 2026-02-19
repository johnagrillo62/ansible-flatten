(playbook "yaml/roles/git/tasks/main.yml"
  (tasks
    (task
      (import_tasks "gitolite.yml")
      (tags "gitolite"))
    (task
      (import_tasks "cgit.yml")
      (tags "cgit"))))
