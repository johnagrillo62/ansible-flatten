(playbook "ansible-examples/wordpress-nginx/roles/common/handlers/main.yml"
  (tasks
    (task "restart iptables"
      (service "name=iptables state=restarted"))))
