(playbook "debops/ansible/roles/global_handlers/handlers/influxdb2.yml"
  (tasks
    (task "Restart influxdb2 service"
      (ansible.builtin.systemd 
        (name "influxdb.service")
        (state "restarted")))))
