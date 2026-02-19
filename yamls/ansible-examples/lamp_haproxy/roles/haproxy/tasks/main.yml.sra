(playbook "ansible-examples/lamp_haproxy/roles/haproxy/tasks/main.yml"
  (tasks
    (task "Download and install haproxy"
      (yum "name=haproxy state=present"))
    (task "Configure the haproxy cnf file with hosts"
      (template "src=haproxy.cfg.j2 dest=/etc/haproxy/haproxy.cfg")
      (notify "restart haproxy"))
    (task "Start the haproxy service"
      (service "name=haproxy state=started enabled=yes"))))
