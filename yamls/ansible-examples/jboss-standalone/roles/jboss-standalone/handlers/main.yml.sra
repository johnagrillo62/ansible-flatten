(playbook "ansible-examples/jboss-standalone/roles/jboss-standalone/handlers/main.yml"
  (tasks
    (task "restart jboss"
      (service 
        (name "jboss")
        (state "restarted")))
    (task "restart iptables"
      (service 
        (name "iptables")
        (state "restarted")))))
