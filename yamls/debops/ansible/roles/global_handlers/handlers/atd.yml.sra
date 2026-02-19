(playbook "debops/ansible/roles/global_handlers/handlers/atd.yml"
  (tasks
    (task "Reload systemd units"
      (ansible.builtin.systemd 
        (daemon_reload "True"))
      (when "ansible_service_mgr == 'systemd'"))
    (task "Restart atd"
      (ansible.builtin.service 
        (name "atd")
        (state "restarted"))
      (when "not ansible_check_mode"))))
