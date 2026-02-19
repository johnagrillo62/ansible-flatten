(playbook "kubespray/roles/etcd/handlers/backup.yml"
  (tasks
    (task "Refresh Time Fact"
      (setup 
        (filter "ansible_date_time"))
      (listen "Restart etcd")
      (when "etcd_cluster_is_healthy.rc == 0"))
    (task "Set Backup Directory"
      (set_fact 
        (etcd_backup_directory (jinja "{{ etcd_backup_prefix }}") "/etcd-" (jinja "{{ ansible_date_time.date }}") "_" (jinja "{{ ansible_date_time.time }}")))
      (listen "Restart etcd"))
    (task "Create Backup Directory"
      (file 
        (path (jinja "{{ etcd_backup_directory }}"))
        (state "directory")
        (owner "root")
        (group "root")
        (mode "0600"))
      (listen "Restart etcd")
      (when "etcd_cluster_is_healthy.rc == 0"))
    (task "Stat etcd v2 data directory"
      (stat 
        (path (jinja "{{ etcd_data_dir }}") "/member")
        (get_attributes "false")
        (get_checksum "false")
        (get_mime "false"))
      (listen "Restart etcd")
      (register "etcd_data_dir_member")
      (when "etcd_cluster_is_healthy.rc == 0"))
    (task "Backup etcd v2 data"
      (command (jinja "{{ bin_dir }}") "/etcdctl backup
  --data-dir " (jinja "{{ etcd_data_dir }}") "
  --backup-dir " (jinja "{{ etcd_backup_directory }}"))
      (listen "Restart etcd")
      (when (list
          "etcd_data_dir_member.stat.exists"
          "etcd_cluster_is_healthy.rc == 0"
          "etcd_version is version('3.6.0', '<')"))
      (environment 
        (ETCDCTL_API "2"))
      (retries "3")
      (register "backup_v2_command")
      (until "backup_v2_command.rc == 0")
      (delay (jinja "{{ retry_stagger | random + 3 }}")))
    (task "Backup etcd v3 data"
      (command (jinja "{{ bin_dir }}") "/etcdctl
  snapshot save " (jinja "{{ etcd_backup_directory }}") "/snapshot.db")
      (listen "Restart etcd")
      (environment 
        (ETCDCTL_API "3")
        (ETCDCTL_ENDPOINTS (jinja "{{ etcd_access_addresses.split(',') | first }}"))
        (ETCDCTL_CERT (jinja "{{ etcd_cert_dir }}") "/admin-" (jinja "{{ inventory_hostname }}") ".pem")
        (ETCDCTL_KEY (jinja "{{ etcd_cert_dir }}") "/admin-" (jinja "{{ inventory_hostname }}") "-key.pem")
        (ETCDCTL_CACERT (jinja "{{ etcd_cert_dir }}") "/ca.pem"))
      (retries "3")
      (register "etcd_backup_v3_command")
      (until "etcd_backup_v3_command.rc == 0")
      (delay (jinja "{{ retry_stagger | random + 3 }}"))
      (when "etcd_cluster_is_healthy.rc == 0"))))
