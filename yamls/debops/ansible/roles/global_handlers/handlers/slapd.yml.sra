(playbook "debops/ansible/roles/global_handlers/handlers/slapd.yml"
  (tasks
    (task "Restart slapd"
      (ansible.builtin.service 
        (name "slapd")
        (state "restarted")))))
