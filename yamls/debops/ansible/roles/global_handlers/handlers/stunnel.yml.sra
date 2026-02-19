(playbook "debops/ansible/roles/global_handlers/handlers/stunnel.yml"
  (tasks
    (task "Restart stunnel"
      (ansible.builtin.service 
        (name "stunnel4")
        (state "restarted")))
    (task "Reload stunnel"
      (ansible.builtin.service 
        (name "stunnel4")
        (state "reloaded")))))
