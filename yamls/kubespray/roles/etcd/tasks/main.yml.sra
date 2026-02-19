(playbook "kubespray/roles/etcd/tasks/main.yml"
  (tasks
    (task "Check etcd certs"
      (include_tasks "check_certs.yml")
      (when "cert_management == \"script\"")
      (tags (list
          "etcd-secrets"
          "facts")))
    (task "Generate etcd certs"
      (include_tasks "gen_certs_script.yml")
      (when (list
          "cert_management == \"script\""))
      (tags (list
          "etcd-secrets")))
    (task "Trust etcd CA"
      (include_tasks "upd_ca_trust.yml")
      (when (list
          "('etcd' in group_names) or ('kube_control_plane' in group_names)"))
      (tags (list
          "etcd-secrets")))
    (task "Trust etcd CA on nodes if needed"
      (include_tasks "upd_ca_trust.yml")
      (when (list
          "kube_network_plugin in [\"calico\", \"flannel\", \"cilium\"] or cilium_deploy_additionally"
          "kube_network_plugin != \"calico\" or calico_datastore == \"etcd\""
          "('k8s_cluster' in group_names)"))
      (tags (list
          "etcd-secrets")))
    (task "Gen_certs | Get etcd certificate serials"
      (command "openssl x509 -in " (jinja "{{ etcd_cert_dir }}") "/node-" (jinja "{{ inventory_hostname }}") ".pem -noout -serial")
      (register "etcd_client_cert_serial_result")
      (changed_when "false")
      (check_mode "false")
      (when (list
          "kube_network_plugin in [\"calico\", \"flannel\", \"cilium\"] or cilium_deploy_additionally"
          "kube_network_plugin != \"calico\" or calico_datastore == \"etcd\""
          "('k8s_cluster' in group_names)"))
      (tags (list
          "control-plane"
          "network")))
    (task "Set etcd_client_cert_serial"
      (set_fact 
        (etcd_client_cert_serial (jinja "{{ etcd_client_cert_serial_result.stdout.split('=')[1] }}")))
      (when (list
          "kube_network_plugin in [\"calico\", \"flannel\", \"cilium\"] or cilium_deploy_additionally"
          "kube_network_plugin != \"calico\" or calico_datastore == \"etcd\""
          "('k8s_cluster' in group_names)"))
      (tags (list
          "control-plane"
          "network")))
    (task "Install etcd"
      (include_tasks "install_" (jinja "{{ etcd_deployment_type }}") ".yml")
      (when "('etcd' in group_names)")
      (tags (list
          "upgrade")))
    (task "Install etcdctl and etcdutl binary"
      (import_role 
        (name "etcdctl_etcdutl"))
      (tags (list
          "etcdctl"
          "etcdutl"
          "upgrade"))
      (when (list
          "('etcd' in group_names)"
          "etcd_cluster_setup")))
    (task "Configure etcd"
      (include_tasks "configure.yml")
      (when "('etcd' in group_names)"))
    (task "Refresh etcd config"
      (include_tasks "refresh_config.yml")
      (when "('etcd' in group_names)"))
    (task "Restart etcd if certs changed"
      (command "/bin/true")
      (notify "Restart etcd")
      (when (list
          "('etcd' in group_names)"
          "etcd_cluster_setup"
          "etcd_secret_changed | default(false)")))
    (task "Restart etcd-events if certs changed"
      (command "/bin/true")
      (notify "Restart etcd")
      (when (list
          "('etcd' in group_names)"
          "etcd_events_cluster_setup"
          "etcd_secret_changed | default(false)")))
    (task "Refresh etcd config again for idempotency"
      (include_tasks "refresh_config.yml")
      (when "('etcd' in group_names)"))))
