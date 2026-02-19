(playbook "debops/ansible/roles/global_handlers/handlers/rspamd.yml"
  (tasks
    (task "Restart rspamd"
      (ansible.builtin.service 
        (name "rspamd")
        (state "restarted")))))
