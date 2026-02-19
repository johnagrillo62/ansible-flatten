(playbook "ansible-examples/wordpress-nginx/roles/mysql/handlers/main.yml"
  (tasks
    (task "restart mysql"
      (service "name=mysqld state=restarted"))))
