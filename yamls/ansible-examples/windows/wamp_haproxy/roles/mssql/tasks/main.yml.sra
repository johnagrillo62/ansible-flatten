(playbook "ansible-examples/windows/wamp_haproxy/roles/mssql/tasks/main.yml"
  (tasks
    (task "Create Application Database"
      (script "create-db.ps1"))))
