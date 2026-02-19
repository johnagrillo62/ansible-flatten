(playbook "debops/ansible/roles/networkd/handlers/main.yml"
  (tasks
    (task "Restart systemd-networkd service"
      (ansible.builtin.systemd 
        (name "systemd-networkd.service")
        (state "restarted"))
      (when "(ansible_service_mgr == 'systemd' and networkd__unattended_restart | bool)"))))
