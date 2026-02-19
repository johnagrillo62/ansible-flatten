(playbook "debops/ansible/roles/global_handlers/handlers/zabbix_agent.yml"
  (tasks
    (task "Check zabbix-agent and restart"
      (ansible.builtin.command "/usr/sbin/zabbix_agentd --print")
      (register "global_handlers__zabbix_agent_register_config_test_c")
      (changed_when "global_handlers__zabbix_agent_register_config_test_c.changed | bool")
      (when "zabbix_agent__flavor == 'C'")
      (notify (list
          "Restart zabbix-agent")))
    (task "Check zabbix-agent2 and restart"
      (ansible.builtin.command "/usr/sbin/zabbix_agent2 --print")
      (register "global_handlers__zabbix_agent_register_config_test_go")
      (changed_when "global_handlers__zabbix_agent_register_config_test_go.changed | bool")
      (when "zabbix_agent__flavor == 'Go'")
      (notify (list
          "Restart zabbix-agent2")))
    (task "Restart zabbix-agent"
      (ansible.builtin.service 
        (name "zabbix-agent")
        (state "restarted")))
    (task "Restart zabbix-agent2"
      (ansible.builtin.service 
        (name "zabbix-agent2")
        (state "restarted")))))
