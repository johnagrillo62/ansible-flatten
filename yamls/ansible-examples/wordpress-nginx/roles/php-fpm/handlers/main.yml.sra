(playbook "ansible-examples/wordpress-nginx/roles/php-fpm/handlers/main.yml"
  (tasks
    (task "restart php-fpm"
      (service "name=php-fpm state=restarted"))))
