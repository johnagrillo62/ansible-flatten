(playbook "kubespray/roles/kubernetes/control-plane/defaults/main/etcd.yml"
  (etcd_owner "etcd")
  (etcd_cert_alt_names (list
      "etcd.kube-system.svc." (jinja "{{ dns_domain }}")
      "etcd.kube-system.svc"
      "etcd.kube-system"
      "etcd"))
  (etcd_cert_alt_ips (list))
  (etcd_heartbeat_interval "250")
  (etcd_election_timeout "5000")
  (etcd_metrics "basic")
  (etcd_extra_vars )
  (etcd_compaction_retention "8"))
