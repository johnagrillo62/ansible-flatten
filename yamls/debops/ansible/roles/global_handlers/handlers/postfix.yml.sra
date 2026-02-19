(playbook "debops/ansible/roles/global_handlers/handlers/postfix.yml"
  (tasks
    (task "Process Postfix Makefile"
      (ansible.builtin.command "make")
      (environment 
        (LC_MESSAGES "C"))
      (args 
        (chdir "/etc/postfix"))
      (register "global_handlers__postfix_register_make")
      (notify (list
          "Check postfix and reload"))
      (changed_when "not global_handlers__postfix_register_make.stdout.startswith(\"make: Nothing to be done\")"))
    (task "Check postfix and restart"
      (ansible.builtin.command "/usr/sbin/postfix -c /etc/postfix check")
      (register "global_handlers__postfix_register_check_restart")
      (changed_when "global_handlers__postfix_register_check_restart.changed | bool")
      (notify (list
          "Restart postfix")))
    (task "Check postfix and reload"
      (ansible.builtin.command "/usr/sbin/postfix -c /etc/postfix check")
      (register "global_handlers__postfix_register_check_reload")
      (changed_when "global_handlers__postfix_register_check_reload.changed | bool")
      (notify (list
          "Reload postfix")))
    (task "Restart postfix"
      (ansible.builtin.service 
        (name "postfix")
        (state "restarted")))
    (task "Reload postfix"
      (ansible.builtin.service 
        (name "postfix")
        (state "reloaded")))))
