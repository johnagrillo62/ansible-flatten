(playbook "debops/ansible/roles/global_handlers/handlers/keepalived.yml"
  (tasks
    (task "Check keepalived configuration and restart"
      (ansible.builtin.command "keepalived --config-test")
      (register "global_handlers__keepalived_register_config_restart")
      (changed_when "global_handlers__keepalived_register_config_restart.changed | bool")
      (notify (list
          "Restart keepalived")))
    (task "Check keepalived configuration and reload"
      (ansible.builtin.command "keepalived --config-test")
      (register "global_handlers__keepalived_register_config_reload")
      (changed_when "global_handlers__keepalived_register_config_reload.changed | bool")
      (notify (list
          "Reload keepalived")))
    (task "Restart keepalived"
      (ansible.builtin.service 
        (name "keepalived")
        (state "restarted")))
    (task "Reload keepalived"
      (ansible.builtin.service 
        (name "keepalived")
        (state "reloaded")))))
