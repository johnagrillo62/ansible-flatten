(playbook "debops/ansible/roles/global_handlers/handlers/monit.yml"
  (tasks
    (task "Test monit and reload"
      (ansible.builtin.command "monit -t")
      (register "global_handlers__monit_register_check_config")
      (changed_when "global_handlers__monit_register_check_config.changed | bool")
      (notify (list
          "Reload monit")))
    (task "Reload monit"
      (ansible.builtin.service 
        (name "monit")
        (state "reloaded")))))
