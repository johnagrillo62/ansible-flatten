(playbook "ansible-examples/wordpress-nginx_rhel7/roles/nginx/handlers/main.yml"
  (tasks
    (task "restart nginx"
      (service "name=nginx state=restarted enabled=yes"))))
