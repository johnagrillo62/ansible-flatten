(playbook "ansible-tuto/step-12/roles/haproxy/handlers/main.yml"
  (tasks
    (task "restart haproxy"
      (service 
        (name "haproxy")
        (state "restarted")))))
