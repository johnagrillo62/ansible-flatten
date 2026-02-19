(playbook "ansible-tuto/step-13/roles/haproxy/handlers/main.yml"
  (tasks
    (task "restart haproxy"
      (service 
        (name "haproxy")
        (state "restarted")))))
