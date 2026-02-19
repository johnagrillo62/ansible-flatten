(playbook "debops/ansible/roles/global_handlers/handlers/lldpd.yml"
  (tasks
    (task "Restart lldpd"
      (ansible.builtin.service 
        (name "lldpd")
        (state "restarted")))))
