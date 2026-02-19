(playbook "debops/ansible/roles/global_handlers/handlers/saslauthd.yml"
  (tasks
    (task "Restart saslauthd"
      (ansible.builtin.service 
        (name "saslauthd")
        (state "restarted")))))
