(playbook "debops/ansible/roles/global_handlers/handlers/icinga.yml"
  (tasks
    (task "Check icinga2 configuration and restart"
      (ansible.builtin.command "icinga2 daemon -C")
      (register "global_handlers__icinga_register_config_test")
      (changed_when "global_handlers__icinga_register_config_test.changed | bool")
      (notify (list
          "Restart icinga2")))
    (task "Restart icinga2"
      (ansible.builtin.service 
        (name "icinga2")
        (state "restarted")))))
