(playbook "debops/ansible/roles/global_handlers/handlers/resolved.yml"
  (tasks
    (task "Restart systemd-resolved service"
      (ansible.builtin.systemd 
        (name "systemd-resolved.service")
        (state "restarted"))
      (listen (list
          "Restart DNS resolver"))
      (when (list
          "ansible_service_mgr == 'systemd'"
          "(ansible_local.resolved.state | d('disabled')) == 'enabled'")))))
