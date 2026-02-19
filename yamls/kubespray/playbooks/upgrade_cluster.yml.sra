(playbook "kubespray/playbooks/upgrade_cluster.yml"
  (tasks
    (task "Common tasks for every playbooks"
      (import_playbook "boilerplate.yml"))
    (task "Gather facts"
      (import_playbook "internal_facts.yml"))
    (task "Download images to ansible host cache via first kube_control_plane node"
      (hosts "kube_control_plane[0]")
      (gather_facts "false")
      (roles (list
          
          (role "kubespray_defaults")
          (when "not skip_downloads and download_run_once and not download_localhost")
          
          (role "kubernetes/preinstall")
          (tags "preinstall")
          (when "not skip_downloads and download_run_once and not download_localhost")
          
          (role "download")
          (tags "download")
          (when "not skip_downloads and download_run_once and not download_localhost")))
      (any_errors_fatal (jinja "{{ any_errors_fatal | default(true) }}"))
      (environment (jinja "{{ proxy_disable_env }}")))
    (task "Prepare nodes for upgrade"
      (hosts "k8s_cluster:etcd:calico_rr")
      (gather_facts "false")
      (roles (list
          
          (role "kubespray_defaults")
          
          (role "kubernetes/preinstall")
          (tags "preinstall")
          
          (role "download")
          (tags "download")
          (when "not skip_downloads")))
      (any_errors_fatal (jinja "{{ any_errors_fatal | default(true) }}"))
      (environment (jinja "{{ proxy_disable_env }}")))
    (task "Upgrade container engine on non-cluster nodes"
      (hosts "etcd:calico_rr:!k8s_cluster")
      (gather_facts "false")
      (serial (jinja "{{ serial | default('20%') }}"))
      (roles (list
          
          (role "kubespray_defaults")
          
          (role "container-engine")
          (tags "container-engine")
          (when "deploy_container_engine")))
      (any_errors_fatal (jinja "{{ any_errors_fatal | default(true) }}"))
      (environment (jinja "{{ proxy_disable_env }}")))
    (task "Install etcd"
      (import_playbook "install_etcd.yml")
      (vars 
        (etcd_cluster_setup "true")
        (etcd_events_cluster_setup (jinja "{{ etcd_events_cluster_enabled }}"))))
    (task "Handle upgrades to control plane components first to maintain backwards compat."
      (gather_facts "false")
      (hosts "kube_control_plane")
      (serial "1")
      (roles (list
          
          (role "kubespray_defaults")
          
          (role "upgrade/pre-upgrade")
          (tags "pre-upgrade")
          
          (role "upgrade/system-upgrade")
          (tags "system-upgrade")
          
          (role "download")
          (tags "download")
          (when "system_upgrade and system_upgrade_reboot != 'never' and not skip_downloads")
          
          (role "kubernetes-apps/kubelet-csr-approver")
          (tags "kubelet-csr-approver")
          
          (role "container-engine")
          (tags "container-engine")
          (when "deploy_container_engine")
          
          (role "kubernetes/node")
          (tags "node")
          
          (role "kubernetes/control-plane")
          (tags "control-plane")
          (upgrade_cluster_setup "true")
          
          (role "kubernetes/client")
          (tags "client")
          
          (role "kubernetes/node-label")
          (tags "node-label")
          
          (role "kubernetes/node-taint")
          (tags "node-taint")
          
          (role "kubernetes-apps/cluster_roles")
          (tags "cluster-roles")
          
          (role "kubernetes-apps")
          (tags "csi-driver")
          
          (role "upgrade/post-upgrade")
          (tags "post-upgrade")))
      (any_errors_fatal (jinja "{{ any_errors_fatal | default(true) }}"))
      (environment (jinja "{{ proxy_disable_env }}")))
    (task "Upgrade calico and external cloud provider on all control plane nodes, calico-rrs, and nodes"
      (hosts "kube_control_plane:calico_rr:kube_node")
      (gather_facts "false")
      (serial (jinja "{{ serial | default('20%') }}"))
      (roles (list
          
          (role "kubespray_defaults")
          
          (role "kubernetes-apps/external_cloud_controller")
          (tags "external-cloud-controller")
          
          (role "network_plugin")
          (tags "network")
          
          (role "kubernetes-apps/policy_controller")
          (tags "policy-controller")))
      (any_errors_fatal (jinja "{{ any_errors_fatal | default(true) }}"))
      (environment (jinja "{{ proxy_disable_env }}")))
    (task "Finally handle worker upgrades, based on given batch size"
      (hosts "kube_node:calico_rr:!kube_control_plane")
      (gather_facts "false")
      (serial (jinja "{{ serial | default('20%') }}"))
      (roles (list
          
          (role "kubespray_defaults")
          
          (role "upgrade/pre-upgrade")
          (tags "pre-upgrade")
          
          (role "upgrade/system-upgrade")
          (tags "system-upgrade")
          
          (role "download")
          (tags "download")
          (when "system_upgrade and system_upgrade_reboot != 'never' and not skip_downloads")
          
          (role "container-engine")
          (tags "container-engine")
          (when "deploy_container_engine")
          
          (role "kubernetes/node")
          (tags "node")
          
          (role "kubernetes/kubeadm")
          (tags "kubeadm")
          
          (role "kubernetes/node-label")
          (tags "node-label")
          
          (role "kubernetes/node-taint")
          (tags "node-taint")
          
          (role "upgrade/post-upgrade")
          (tags "post-upgrade")))
      (any_errors_fatal (jinja "{{ any_errors_fatal | default(true) }}"))
      (environment (jinja "{{ proxy_disable_env }}")))
    (task "Patch Kubernetes for Windows"
      (hosts "kube_control_plane[0]")
      (gather_facts "false")
      (roles (list
          
          (role "kubespray_defaults")
          
          (role "win_nodes/kubernetes_patch")
          (tags (list
              "control-plane"
              "win_nodes"))))
      (any_errors_fatal "true")
      (environment (jinja "{{ proxy_disable_env }}")))
    (task "Install Calico Route Reflector"
      (hosts "calico_rr")
      (gather_facts "false")
      (roles (list
          
          (role "kubespray_defaults")
          
          (role "network_plugin/calico/rr")
          (tags "network")))
      (any_errors_fatal (jinja "{{ any_errors_fatal | default(true) }}"))
      (environment (jinja "{{ proxy_disable_env }}")))
    (task "Install Kubernetes apps"
      (hosts "kube_control_plane")
      (gather_facts "false")
      (roles (list
          
          (role "kubespray_defaults")
          
          (role "kubernetes-apps/ingress_controller")
          (tags "ingress-controller")
          
          (role "kubernetes-apps/external_provisioner")
          (tags "external-provisioner")
          
          (role "kubernetes-apps")
          (tags "apps")))
      (any_errors_fatal (jinja "{{ any_errors_fatal | default(true) }}"))
      (environment (jinja "{{ proxy_disable_env }}")))
    (task "Apply resolv.conf changes now that cluster DNS is up"
      (hosts "k8s_cluster")
      (gather_facts "false")
      (roles (list
          
          (role "kubespray_defaults")
          
          (role "kubernetes/preinstall")
          (when "dns_mode != 'none' and resolvconf_mode == 'host_resolvconf'")
          (tags "resolvconf")
          (dns_late "true")))
      (any_errors_fatal (jinja "{{ any_errors_fatal | default(true) }}"))
      (environment (jinja "{{ proxy_disable_env }}")))))
