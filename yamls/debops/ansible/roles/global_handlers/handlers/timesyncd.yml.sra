(playbook "debops/ansible/roles/global_handlers/handlers/timesyncd.yml"
  (tasks
    (task "Restart systemd-timesyncd service"
      (ansible.builtin.systemd 
        (name "systemd-timesyncd.service")
        (state "restarted"))
      (when "ansible_service_mgr == 'systemd'"))))
