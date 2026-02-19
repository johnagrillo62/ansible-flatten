(playbook "ansible-examples/lamp_haproxy/roles/nagios/handlers/main.yml"
  (tasks
    (task "restart httpd"
      (service "name=httpd state=restarted"))
    (task "restart nagios"
      (service "name=nagios state=restarted"))))
