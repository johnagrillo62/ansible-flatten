(playbook "debops/ansible/roles/global_handlers/handlers/samba.yml"
  (tasks
    (task "Check samba config"
      (ansible.builtin.command "testparm -s")
      (register "global_handlers__samba_register_test_config")
      (changed_when "global_handlers__samba_register_test_config.changed | bool")
      (notify (list
          "Reload nmbd"
          "Reload smbd")))
    (task "Reload nmbd"
      (ansible.builtin.service 
        (name "nmbd")
        (state "restarted")))
    (task "Reload smbd"
      (ansible.builtin.service 
        (name "smbd")
        (state "reloaded")))))
