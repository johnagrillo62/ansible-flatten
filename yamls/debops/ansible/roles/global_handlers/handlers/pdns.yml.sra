(playbook "debops/ansible/roles/global_handlers/handlers/pdns.yml"
  (tasks
    (task "Restart pdns"
      (ansible.builtin.service 
        (name "pdns")
        (state "restarted")))))
