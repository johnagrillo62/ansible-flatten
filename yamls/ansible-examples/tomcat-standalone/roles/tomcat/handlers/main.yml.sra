(playbook "ansible-examples/tomcat-standalone/roles/tomcat/handlers/main.yml"
  (tasks
    (task "restart tomcat"
      (service "name=tomcat state=restarted"))
    (task "restart iptables"
      (service "name=iptables state=restarted"))))
