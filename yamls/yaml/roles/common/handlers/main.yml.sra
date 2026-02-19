(playbook "yaml/roles/common/handlers/main.yml"
  (tasks
    (task "restart ntp"
      (service "name=ntp state=restarted"))
    (task "restart apache"
      (service "name=apache2 state=restarted"))
    (task "restart fail2ban"
      (service "name=fail2ban state=restarted"))
    (task "restart ssh"
      (service "name=ssh state=restarted"))))
