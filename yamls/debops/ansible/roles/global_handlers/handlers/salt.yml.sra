(playbook "debops/ansible/roles/global_handlers/handlers/salt.yml"
  (tasks
    (task "Restart salt-master"
      (ansible.builtin.service 
        (name "salt-master")
        (state "restarted")))))
