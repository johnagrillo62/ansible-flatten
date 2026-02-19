(playbook "kubespray/roles/etcd/handlers/backup_cleanup.yml"
  (tasks
    (task "Find old etcd backups"
      (ansible.builtin.find 
        (file_type "directory")
        (recurse "false")
        (paths (jinja "{{ etcd_backup_prefix }}"))
        (patterns "etcd-*"))
      (listen "Restart etcd")
      (register "_etcd_backups")
      (when "etcd_backup_retention_count >= 0"))
    (task "Remove old etcd backups"
      (ansible.builtin.file 
        (state "absent")
        (path (jinja "{{ item }}")))
      (listen "Restart etcd")
      (loop (jinja "{{ (_etcd_backups.files | sort(attribute='ctime', reverse=True))[etcd_backup_retention_count:] | map(attribute='path') }}"))
      (when "etcd_backup_retention_count >= 0"))))
