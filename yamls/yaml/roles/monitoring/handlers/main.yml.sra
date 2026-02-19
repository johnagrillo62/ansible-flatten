(playbook "yaml/roles/monitoring/handlers/main.yml"
  (tasks
    (task "restart monit"
      (service "name=monit state=restarted"))
    (task "restart collectd"
      (service "name=collectd state=restarted"))
    (task "restart rspamd"
      (service "name=rspamd state=restarted"))))
