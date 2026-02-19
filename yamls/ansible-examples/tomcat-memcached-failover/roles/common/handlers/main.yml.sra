(playbook "ansible-examples/tomcat-memcached-failover/roles/common/handlers/main.yml"
  (tasks
    (task "restart iptables"
      (service "name=iptables state=restarted"))))
