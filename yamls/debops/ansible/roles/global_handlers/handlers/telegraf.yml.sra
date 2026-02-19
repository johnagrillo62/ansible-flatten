(playbook "debops/ansible/roles/global_handlers/handlers/telegraf.yml"
  (tasks
    (task "Check telegraf and restart"
      (ansible.builtin.command "/usr/bin/telegraf --test --config /etc/telegraf/telegraf.conf --config-directory /etc/telegraf/telegraf.d")
      (register "global_handlers__telegraf_register_config_test")
      (changed_when "global_handlers__telegraf_register_config_test.changed | bool")
      (notify (list
          "Restart telegraf")))
    (task "Restart telegraf"
      (ansible.builtin.service 
        (name "telegraf")
        (state "restarted")))))
