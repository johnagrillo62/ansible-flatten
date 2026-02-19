(playbook "debops/ansible/roles/global_handlers/handlers/sks.yml"
  (tasks
    (task "Restart sks"
      (ansible.builtin.service 
        (name "sks")
        (state "restarted")))))
