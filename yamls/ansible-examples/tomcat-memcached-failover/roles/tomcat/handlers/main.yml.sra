(playbook "ansible-examples/tomcat-memcached-failover/roles/tomcat/handlers/main.yml"
  (tasks
    (task "restart tomcat"
      (service "name=tomcat state=restarted"))))
