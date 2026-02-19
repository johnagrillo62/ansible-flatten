(playbook "debops/ansible/roles/global_handlers/handlers/tftpd.yml"
  (tasks
    (task "Restart tftpd-hpa"
      (ansible.builtin.service 
        (name "tftpd-hpa")
        (state "restarted")))))
