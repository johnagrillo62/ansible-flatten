(playbook "ansible-examples/tomcat-memcached-failover/roles/memcached/handlers/main.yml"
  (tasks
    (task "restart memcached"
      (service "name=memcached state=restarted"))))
