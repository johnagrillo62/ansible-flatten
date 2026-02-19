(playbook "debops/ansible/roles/global_handlers/handlers/mailman.yml"
  (tasks
    (task "Restart mailman3"
      (ansible.builtin.service 
        (name "mailman3")
        (state "restarted")))
    (task "Restart mailman3-web"
      (ansible.builtin.service 
        (name "mailman3-web")
        (state "restarted")))))
