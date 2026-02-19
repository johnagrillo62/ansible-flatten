(playbook "ansible-examples/wordpress-nginx_rhel7/roles/nginx/tasks/main.yml"
  (tasks
    (task "Install nginx"
      (yum "name=nginx state=present"))
    (task "Copy nginx configuration for wordpress"
      (template "src=default.conf dest=/etc/nginx/conf.d/default.conf")
      (notify "restart nginx"))
    (task "insert firewalld rule for nginx"
      (firewalld "port=" (jinja "{{ nginx_port }}") "/tcp permanent=true state=enabled immediate=yes")
      (ignore_errors "yes"))
    (task "http service state"
      (service "name=nginx state=started enabled=yes"))))
