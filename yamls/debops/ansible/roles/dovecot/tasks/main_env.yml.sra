(playbook "debops/ansible/roles/dovecot/tasks/main_env.yml"
  (tasks
    (task "Remove ferm 'debops-legacy-input-rules' file"
      (ansible.builtin.file 
        (path "/etc/ferm/filter-input.d/dovecot.conf")
        (state "absent")))))
