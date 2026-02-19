(playbook "ansible-examples/wordpress-nginx_rhel7/roles/mariadb/handlers/main.yml"
  (tasks
    (task "restart mariadb"
      (service "name=mariadb state=restarted"))))
