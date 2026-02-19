(playbook "debops/ansible/roles/global_handlers/handlers/influxdb_server.yml"
  (tasks
    (task "Restart influxdb"
      (ansible.builtin.service 
        (name "influxdb")
        (state "restarted")))))
