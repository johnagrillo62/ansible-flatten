(playbook "ansible-examples/tomcat-memcached-failover/roles/lb-nginx/handlers/main.yml"
  (tasks
    (task "restart nginx"
      (service "name=nginx state=restarted"))))
