(playbook "debops/ansible/roles/global_handlers/handlers/ntp.yml"
  (tasks
    (task "Restart openntpd"
      (ansible.builtin.service 
        (name "openntpd")
        (state "restarted"))
      (when "not ansible_check_mode"))
    (task "Restart ntp"
      (ansible.builtin.service 
        (name "ntp")
        (state "restarted"))
      (when "ntp__daemon == 'ntpd'"))
    (task "Restart systemd-timesyncd"
      (ansible.builtin.service 
        (name "systemd-timesyncd")
        (state "restarted")))
    (task "Restart chrony"
      (ansible.builtin.service 
        (name "chrony")
        (state "restarted")))))
