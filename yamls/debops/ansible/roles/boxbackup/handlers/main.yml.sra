(playbook "debops/ansible/roles/boxbackup/handlers/main.yml"
  (tasks
    (task "Restart boxbackup-server"
      (ansible.builtin.service 
        (name "boxbackup-server")
        (state "restarted")))
    (task "Restart boxbackup-client"
      (ansible.builtin.service 
        (name "boxbackup-client")
        (state "restarted")))))
