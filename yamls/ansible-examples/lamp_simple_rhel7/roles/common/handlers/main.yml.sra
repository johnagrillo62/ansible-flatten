(playbook "ansible-examples/lamp_simple_rhel7/roles/common/handlers/main.yml"
  (tasks
    (task "restart ntp"
      (service "name=ntpd state=restarted"))))
