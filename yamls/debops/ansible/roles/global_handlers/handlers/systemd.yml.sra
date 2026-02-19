(playbook "debops/ansible/roles/global_handlers/handlers/systemd.yml"
  (tasks
    (task "Reload systemd daemon"
      (ansible.builtin.systemd 
        (daemon_reload "True"))
      (listen (list
          "Reload service manager"))
      (when "ansible_service_mgr == 'systemd'"))
    (task "Create temporary files with systemd-tmpfiles"
      (ansible.builtin.command "systemd-tmpfiles --create")
      (listen (list
          "Create temporary files"))
      (register "global_handlers__systemd_register_tmpfiles")
      (changed_when "global_handlers__systemd_register_tmpfiles.stdout != ''")
      (when "ansible_service_mgr == 'systemd'"))))
