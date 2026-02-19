(playbook "debops/ansible/roles/global_handlers/handlers/bind.yml"
  (tasks
    (task "Test named configuration and restart"
      (ansible.builtin.command "runuser -u bind -- /usr/bin/named-checkconf")
      (register "global_handlers__bind_register_checkconf")
      (changed_when "global_handlers__bind_register_checkconf.changed | bool")
      (notify (list
          "Restart named")))
    (task "Restart named"
      (ansible.builtin.service 
        (name "named")
        (state "restarted")))))
