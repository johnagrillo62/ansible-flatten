(playbook "ansible-examples/lamp_simple/roles/web/handlers/main.yml"
  (tasks
    (task "restart iptables"
      (service 
        (name "iptables")
        (state "restarted")))))
