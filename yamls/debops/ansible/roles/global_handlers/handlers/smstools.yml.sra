(playbook "debops/ansible/roles/global_handlers/handlers/smstools.yml"
  (tasks
    (task "Restart smstools"
      (ansible.builtin.service 
        (name "smstools")
        (state "restarted")))
    (task "Restart xinetd"
      (ansible.builtin.service 
        (name "xinetd")
        (state "restarted")))
    (task "Reload xinetd"
      (ansible.builtin.service 
        (name "xinetd")
        (state "reloaded")))))
