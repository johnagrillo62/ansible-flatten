(playbook "ansible-examples/lamp_haproxy/roles/db/handlers/main.yml"
  (tasks
    (task "restart mysql"
      (service "name=mysqld state=restarted"))))
