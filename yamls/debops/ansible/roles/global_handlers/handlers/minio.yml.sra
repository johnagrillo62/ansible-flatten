(playbook "debops/ansible/roles/global_handlers/handlers/minio.yml"
  (tasks
    (task "Restart minio"
      (ansible.builtin.service 
        (name "minio")
        (state "restarted")))))
