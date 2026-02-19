(playbook "debops/ansible/roles/global_handlers/handlers/metricbeat.yml"
  (tasks
    (task "Test metricbeat configuration and restart"
      (ansible.builtin.command "metricbeat test config")
      (register "global_handlers__metricbeat_register_test_config")
      (changed_when "global_handlers__metricbeat_register_test_config.changed | bool")
      (notify (list
          "Restart metricbeat"
          "Commit changes in etckeeper"))
      (when "(ansible_local.metricbeat.installed | d()) | bool"))
    (task "Test metricbeat output and restart"
      (ansible.builtin.command "metricbeat test output")
      (register "global_handlers__metricbeat_register_test_output")
      (changed_when "global_handlers__metricbeat_register_test_output.changed | bool")
      (notify (list
          "Restart metricbeat"))
      (when "(ansible_local.metricbeat.installed | d()) | bool"))
    (task "Restart metricbeat"
      (ansible.builtin.service 
        (name "metricbeat")
        (state "restarted"))
      (when "(ansible_local.metricbeat.installed | d()) | bool"))))
