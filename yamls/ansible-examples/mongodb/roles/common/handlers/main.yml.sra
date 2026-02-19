(playbook "ansible-examples/mongodb/roles/common/handlers/main.yml"
  (tasks
    (task "restart iptables"
      (service "name=iptables state=restarted"))))
