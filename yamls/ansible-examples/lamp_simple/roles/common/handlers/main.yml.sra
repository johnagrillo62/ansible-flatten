(playbook "ansible-examples/lamp_simple/roles/common/handlers/main.yml"
  (tasks
    (task "restart ntp"
      (service 
        (name "ntpd")
        (state "restarted")))))
