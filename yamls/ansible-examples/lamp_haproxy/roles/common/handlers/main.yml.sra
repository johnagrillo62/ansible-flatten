(playbook "ansible-examples/lamp_haproxy/roles/common/handlers/main.yml"
  (tasks
    (task "restart ntp"
      (service "name=ntpd state=restarted"))
    (task "restart iptables"
      (service "name=iptables state=restarted"))))
