(playbook "debops/ansible/roles/global_handlers/handlers/tgt.yml"
  (tasks
    (task "Reload tgt"
      (ansible.builtin.service 
        (name "tgt")
        (state "reloaded")))))
