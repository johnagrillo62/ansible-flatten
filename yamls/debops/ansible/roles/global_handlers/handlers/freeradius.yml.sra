(playbook "debops/ansible/roles/global_handlers/handlers/freeradius.yml"
  (tasks
    (task "Check freeradius configuration and restart"
      (ansible.builtin.command "freeradius -C")
      (register "global_handlers__freeradius_register_check_config")
      (changed_when "global_handlers__freeradius_register_check_config.changed | bool")
      (notify (list
          "Restart freeradius")))
    (task "Restart freeradius"
      (ansible.builtin.service 
        (name "freeradius")
        (state "restarted")))))
