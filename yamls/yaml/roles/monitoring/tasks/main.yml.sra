(playbook "yaml/roles/monitoring/tasks/main.yml"
  (tasks
    (task
      (import_tasks "monit.yml")
      (tags "monit"))
    (task
      (import_tasks "logwatch.yml")
      (tags "logwatch"))
    (task
      (import_tasks "collectd.yml")
      (tags "collectd"))))
