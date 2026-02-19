(playbook "debops/ansible/roles/global_handlers/handlers/rsyslog.yml"
  (tasks
    (task "Check and restart rsyslogd"
      (ansible.builtin.command "rsyslogd -N 1")
      (notify (list
          "Restart rsyslogd"))
      (register "global_handlers__rsyslog_register_test_config")
      (changed_when "global_handlers__rsyslog_register_test_config.changed | bool")
      (when "(ansible_local.rsyslog.installed | d()) | bool"))
    (task "Restart rsyslogd"
      (ansible.builtin.service 
        (name "rsyslog")
        (state "restarted"))
      (when "(ansible_local.rsyslog.installed | d()) | bool"))))
