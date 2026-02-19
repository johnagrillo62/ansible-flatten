(playbook "debops/ansible/roles/global_handlers/handlers/dnsmasq.yml"
  (tasks
    (task "Test and restart dnsmasq"
      (ansible.builtin.command "dnsmasq --test")
      (register "global_handlers__dnsmasq_register_config_test")
      (changed_when "global_handlers__dnsmasq_register_config_test.changed | bool")
      (notify (list
          "Restart dnsmasq")))
    (task "Restart dnsmasq"
      (ansible.builtin.service 
        (name "dnsmasq")
        (state "restarted")))))
