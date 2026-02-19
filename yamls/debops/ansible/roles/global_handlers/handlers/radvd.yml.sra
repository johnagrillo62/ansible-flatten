(playbook "debops/ansible/roles/global_handlers/handlers/radvd.yml"
  (tasks
    (task "Test radvd and restart"
      (ansible.builtin.command "radvd --configtest")
      (register "global_handlers__radvd_register_test_config")
      (changed_when "global_handlers__radvd_register_test_config.changed | bool")
      (notify (list
          "Restart radvd")))
    (task "Restart radvd"
      (ansible.builtin.service 
        (name "radvd")
        (state "restarted")))))
