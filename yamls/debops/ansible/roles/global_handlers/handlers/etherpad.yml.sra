(playbook "debops/ansible/roles/global_handlers/handlers/etherpad.yml"
  (tasks
    (task "Restart etherpad-lite"
      (ansible.builtin.service 
        (name "etherpad-lite")
        (state "restarted")))))
