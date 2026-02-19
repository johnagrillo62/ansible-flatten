(playbook "ansible-examples/lamp_haproxy/aws/roles/haproxy/handlers/main.yml"
  (tasks
    (task "restart haproxy"
      (service "name=haproxy state=restarted"))
    (task "reload haproxy"
      (service "name=haproxy state=reloaded"))))
