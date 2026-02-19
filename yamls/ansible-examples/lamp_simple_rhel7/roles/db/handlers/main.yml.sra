(playbook "ansible-examples/lamp_simple_rhel7/roles/db/handlers/main.yml"
  (tasks
    (task "restart mariadb"
      (service "name=mariadb state=restarted"))))
