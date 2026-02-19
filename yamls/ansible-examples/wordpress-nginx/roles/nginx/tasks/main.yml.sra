(playbook "ansible-examples/wordpress-nginx/roles/nginx/tasks/main.yml"
  (tasks
    (task "Install nginx"
      (yum "name=nginx state=present"))
    (task "Copy nginx configuration for wordpress"
      (template "src=default.conf dest=/etc/nginx/conf.d/default.conf")
      (notify "restart nginx"))))
