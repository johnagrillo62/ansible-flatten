(playbook "debops/ansible/roles/influxdb2/tasks/main.yml"
  (tasks
    (task "Import DebOps global handlers"
      (ansible.builtin.import_role 
        (name "global_handlers")))
    (task "Import DebOps secret role"
      (ansible.builtin.import_role 
        (name "secret")))
    (task "Enable and start InfluxDBv2 service"
      (ansible.builtin.systemd 
        (name "influxdb.service")
        (state "started")
        (enabled "True")))
    (task "Configure InfluxDBv2 server"
      (ansible.builtin.template 
        (src "etc/influxdb/config.toml.j2")
        (dest "/etc/influxdb/config.toml")
        (mode "0644"))
      (tags (list
          "role::influxdb2:config"))
      (notify (list
          "Restart influxdb2 service")))
    (task "Make sure that Ansible local facts directory exists"
      (ansible.builtin.file 
        (path "/etc/ansible/facts.d")
        (state "directory")
        (mode "0755")))
    (task "Save InfluxDBv2 server local facts"
      (ansible.builtin.template 
        (src "etc/ansible/facts.d/influxdb2.fact.j2")
        (dest "/etc/ansible/facts.d/influxdb2.fact")
        (mode "0755"))
      (notify (list
          "Refresh host facts"))
      (tags (list
          "meta::facts")))
    (task "Re-read local facts if they have been modified"
      (ansible.builtin.meta "flush_handlers"))))
