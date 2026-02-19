(playbook "debops/ansible/roles/global_handlers/handlers/unbound.yml"
  (tasks
    (task "Check unbound configuration and reload"
      (ansible.builtin.command "unbound-checkconf /etc/unbound/unbound.conf")
      (register "global_handlers__unbound_register_config_test")
      (changed_when "global_handlers__unbound_register_config_test.changed | bool")
      (notify (list
          "Reload unbound")))
    (task "Reload unbound"
      (ansible.builtin.service 
        (name "unbound")
        (state "reloaded")))))
