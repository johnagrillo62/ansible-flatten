(playbook "debops/ansible/roles/boxbackup/tasks/main.yml"
  (tasks
    (task "Import DebOps secret role"
      (ansible.builtin.import_role 
        (name "secret")))
    (task "Configure server-side"
      (ansible.builtin.include_tasks "configure_servers.yml")
      (when "boxbackup_server is defined and boxbackup_server == ansible_fqdn"))
    (task "Configure client-side"
      (ansible.builtin.include_tasks "configure_clients.yml")
      (when "boxbackup_server is defined and boxbackup_server != ansible_fqdn"))))
