(playbook "debops/ansible/roles/global_handlers/handlers/nullmailer.yml"
  (tasks
    (task "Restart nullmailer"
      (ansible.builtin.service 
        (name "nullmailer")
        (state "restarted"))
      (when "not ansible_check_mode"))
    (task "Reload xinetd"
      (ansible.builtin.service 
        (name "xinetd")
        (state "reloaded")))))
