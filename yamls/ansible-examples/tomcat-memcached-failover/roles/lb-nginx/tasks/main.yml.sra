(playbook "ansible-examples/tomcat-memcached-failover/roles/lb-nginx/tasks/main.yml"
  (tasks
    (task "Install nginx"
      (yum "name=nginx state=present"))
    (task "Deliver main configuration file"
      (template "src=nginx.conf.j2 dest=/etc/nginx/nginx.conf")
      (notify "restart nginx"))
    (task "Copy configuration file to nginx/sites-avaiable"
      (template "src=default.conf.j2 dest=/etc/nginx/conf.d/default.conf")
      (notify "restart nginx"))
    (task "Make sure nginx start with boot"
      (service "name=nginx state=started enabled=yes"))))
