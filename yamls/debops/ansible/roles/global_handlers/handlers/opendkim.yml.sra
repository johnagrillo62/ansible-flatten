(playbook "debops/ansible/roles/global_handlers/handlers/opendkim.yml"
  (tasks
    (task "Check opendkim and restart"
      (ansible.builtin.command "opendkim -n")
      (register "global_handlers__opendkim_register_check_restart")
      (changed_when "global_handlers__opendkim_register_check_restart.changed | bool")
      (notify (list
          "Restart opendkim")))
    (task "Check opendkim and reload"
      (ansible.builtin.command "opendkim -n")
      (register "global_handlers__opendkim_register_check_reload")
      (changed_when "global_handlers__opendkim_register_check_reload.changed | bool")
      (notify (list
          "Reload opendkim"))
      (when "ansible_local | d() and ansible_local.opendkim | d() and ansible_local.opendkim.installed is defined and ansible_local.opendkim.installed | bool"))
    (task "Restart opendkim"
      (ansible.builtin.service 
        (name "opendkim")
        (state "restarted")))
    (task "Reload opendkim"
      (ansible.builtin.service 
        (name "opendkim")
        (state "reloaded")))))
