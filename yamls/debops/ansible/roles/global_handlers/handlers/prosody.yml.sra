(playbook "debops/ansible/roles/global_handlers/handlers/prosody.yml"
  (tasks
    (task "Restart prosody"
      (ansible.builtin.service 
        (name "prosody")
        (state "restarted")))))
