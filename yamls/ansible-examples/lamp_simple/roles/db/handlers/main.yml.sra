(playbook "ansible-examples/lamp_simple/roles/db/handlers/main.yml"
  (tasks
    (task "restart mysql"
      (service 
        (name "mysqld")
        (state "restarted")))
    (task "restart iptables"
      (service 
        (name "iptables")
        (state "restarted")))))
