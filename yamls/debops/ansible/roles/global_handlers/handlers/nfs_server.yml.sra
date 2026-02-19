(playbook "debops/ansible/roles/global_handlers/handlers/nfs_server.yml"
  (tasks
    (task "Restart nfs-kernel-server service"
      (ansible.builtin.service 
        (name "nfs-kernel-server")
        (state "restarted")))
    (task "Reload NFS exports"
      (ansible.builtin.command "exportfs -ra")
      (register "global_handlers__nfs_server_register_exportfs")
      (changed_when "global_handlers__nfs_server_register_exportfs.changed | bool"))))
