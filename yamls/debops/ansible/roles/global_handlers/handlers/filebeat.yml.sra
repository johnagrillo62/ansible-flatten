(playbook "debops/ansible/roles/global_handlers/handlers/filebeat.yml"
  (tasks
    (task "Test filebeat configuration and restart"
      (ansible.builtin.command "filebeat test config")
      (register "global_handlers__filebeat_register_test_config")
      (changed_when "global_handlers__filebeat_register_test_config.changed | bool")
      (notify (list
          "Restart filebeat"
          "Commit changes in etckeeper"))
      (when "(ansible_local.filebeat.installed | d()) | bool"))
    (task "Test filebeat output and restart"
      (ansible.builtin.command "filebeat test output")
      (register "global_handlers__filebeat_register_test_output")
      (changed_when "global_handlers__filebeat_register_test_output.changed | bool")
      (notify (list
          "Restart filebeat"))
      (when "(ansible_local.filebeat.installed | d()) | bool"))
    (task "Restart filebeat"
      (ansible.builtin.service 
        (name "filebeat")
        (state "restarted"))
      (when "(ansible_local.filebeat.installed | d()) | bool"))))
