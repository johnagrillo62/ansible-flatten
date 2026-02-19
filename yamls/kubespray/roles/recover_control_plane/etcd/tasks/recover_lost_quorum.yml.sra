(playbook "kubespray/roles/recover_control_plane/etcd/tasks/recover_lost_quorum.yml"
  (tasks
    (task "Save etcd snapshot"
      (command (jinja "{{ bin_dir }}") "/etcdctl snapshot save /tmp/snapshot.db")
      (environment 
        (ETCDCTL_CERT (jinja "{{ etcd_cert_dir }}") "/admin-" (jinja "{{ inventory_hostname }}") ".pem")
        (ETCDCTL_KEY (jinja "{{ etcd_cert_dir }}") "/admin-" (jinja "{{ inventory_hostname }}") "-key.pem")
        (ETCDCTL_CACERT (jinja "{{ etcd_cert_dir }}") "/ca.pem")
        (ETCDCTL_ENDPOINTS (jinja "{{ etcd_access_addresses.split(',') | first }}"))
        (ETCDCTL_API "3"))
      (when "etcd_snapshot is not defined"))
    (task "Transfer etcd snapshot to host"
      (copy 
        (src (jinja "{{ etcd_snapshot }}"))
        (dest "/tmp/snapshot.db")
        (mode "0640"))
      (when "etcd_snapshot is defined"))
    (task "Stop etcd"
      (systemd_service 
        (name "etcd")
        (state "stopped")))
    (task "Remove etcd data-dir"
      (file 
        (path (jinja "{{ etcd_data_dir }}"))
        (state "absent")))
    (task "Restore etcd snapshot"
      (shell (jinja "{{ bin_dir }}") "/etcdctl snapshot restore /tmp/snapshot.db --name " (jinja "{{ etcd_member_name }}") " --initial-cluster " (jinja "{{ etcd_member_name }}") "=" (jinja "{{ etcd_peer_url }}") " --initial-cluster-token k8s_etcd --initial-advertise-peer-urls " (jinja "{{ etcd_peer_url }}") " --data-dir " (jinja "{{ etcd_data_dir }}"))
      (environment 
        (ETCDCTL_CERT (jinja "{{ etcd_cert_dir }}") "/admin-" (jinja "{{ inventory_hostname }}") ".pem")
        (ETCDCTL_KEY (jinja "{{ etcd_cert_dir }}") "/admin-" (jinja "{{ inventory_hostname }}") "-key.pem")
        (ETCDCTL_CACERT (jinja "{{ etcd_cert_dir }}") "/ca.pem")
        (ETCDCTL_ENDPOINTS (jinja "{{ etcd_access_addresses }}"))
        (ETCDCTL_API "3")))
    (task "Remove etcd snapshot"
      (file 
        (path "/tmp/snapshot.db")
        (state "absent")))
    (task "Change etcd data-dir owner"
      (file 
        (path (jinja "{{ etcd_data_dir }}"))
        (owner "etcd")
        (group "etcd")
        (recurse "true")))
    (task "Reconfigure etcd"
      (replace 
        (path "/etc/etcd.env")
        (regexp "^(ETCD_INITIAL_CLUSTER=).*")
        (replace "\\1" (jinja "{{ etcd_member_name }}") "=" (jinja "{{ etcd_peer_url }}"))))
    (task "Start etcd"
      (systemd_service 
        (name "etcd")
        (state "started")))))
