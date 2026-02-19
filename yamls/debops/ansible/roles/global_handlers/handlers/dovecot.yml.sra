(playbook "debops/ansible/roles/global_handlers/handlers/dovecot.yml"
  (tasks
    (task "Restart dovecot"
      (ansible.builtin.service 
        (name "dovecot")
        (state "restarted")))))
