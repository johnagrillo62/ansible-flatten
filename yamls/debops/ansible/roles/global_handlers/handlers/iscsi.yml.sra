(playbook "debops/ansible/roles/global_handlers/handlers/iscsi.yml"
  (tasks
    (task "Restart open-iscsi"
      (ansible.builtin.service 
        (name "open-iscsi")
        (state "restarted")))))
