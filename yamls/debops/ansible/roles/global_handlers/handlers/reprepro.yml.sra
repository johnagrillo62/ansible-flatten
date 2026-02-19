(playbook "debops/ansible/roles/global_handlers/handlers/reprepro.yml"
  (tasks
    (task "Restart inoticoming"
      (ansible.builtin.service 
        (name "inoticoming")
        (state "restarted")))))
