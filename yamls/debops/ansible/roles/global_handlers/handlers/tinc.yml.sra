(playbook "debops/ansible/roles/global_handlers/handlers/tinc.yml"
  (tasks
    (task "Reload tinc"
      (ansible.builtin.service 
        (name "tinc")
        (state "reloaded")))))
