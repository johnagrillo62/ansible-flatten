(playbook "kubespray/playbooks/cluster.yml"
  (tasks
    (task "Common tasks for every playbooks"
      (import_playbook "boilerplate.yml"))
    (task "Gather facts"
      (import_playbook "internal_facts.yml"))
    (task "Prepare for etcd install"
      (hosts "k8s_cluster:etcd")
      (gather_facts "false")
      (roles (list
          
          (role "kubespray_defaults")
          
          (role "kubernetes/preinstall")
          (tags "preinstall")
          
          (role "container-engine")
          (tags "container-engine")
          (when "deploy_container_engine")
          
          (role "download")
          (tags "download")
          (when "not skip_downloads")))
      (any_errors_fatal (jinja "{{ any_errors_fatal | default(true) }}"))
      (environment (jinja "{{ proxy_disable_env }}")))
    (task "Install etcd"
      (import_playbook "install_etcd.yml")
      (vars 
        (etcd_cluster_setup "true")
        (etcd_events_cluster_setup (jinja "{{ etcd_events_cluster_enabled }}"))))
    (task "Install Kubernetes nodes"
      (hosts "k8s_cluster")
      (gather_facts "false")
      (roles (list
          
          (role "kubespray_defaults")
          
          (role "kubernetes/node")
          (tags "node")))
      (any_errors_fatal (jinja "{{ any_errors_fatal | default(true) }}"))
      (environment (jinja "{{ proxy_disable_env }}")))
    (task "Install the control plane"
      (hosts "kube_control_plane")
      (gather_facts "false")
      (roles (list
          
          (role "kubespray_defaults")
          
          (role "kubernetes/control-plane")
          (tags "control-plane")
          
          (role "kubernetes/client")
          (tags "client")
          
          (role "kubernetes-apps/cluster_roles")
          (tags "cluster-roles")))
      (any_errors_fatal (jinja "{{ any_errors_fatal | default(true) }}"))
      (environment (jinja "{{ proxy_disable_env }}")))
    (task "Invoke kubeadm and install a CNI"
      (hosts "k8s_cluster")
      (gather_facts "false")
      (roles (list
          
          (role "kubespray_defaults")
          
          (role "kubernetes/kubeadm")
          (tags "kubeadm")
          
          (role "kubernetes/node-label")
          (tags "node-label")
          
          (role "kubernetes/node-taint")
          (tags "node-taint")
          
          (role "kubernetes-apps/common_crds")
          
          (role "network_plugin")
          (tags "network")))
      (any_errors_fatal (jinja "{{ any_errors_fatal | default(true) }}"))
      (environment (jinja "{{ proxy_disable_env }}")))
    (task "Install Calico Route Reflector"
      (hosts "calico_rr")
      (gather_facts "false")
      (roles (list
          
          (role "kubespray_defaults")
          
          (role "network_plugin/calico/rr")
          (tags (list
              "network"
              "calico_rr"))))
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
      (any_errors_fatal (jinja "{{ any_errors_fatal | default(true) }}"))
      (environment (jinja "{{ proxy_disable_env }}")))
    (task "Install Kubernetes apps"
      (hosts "kube_control_plane")
      (gather_facts "false")
      (roles (list
          
          (role "kubespray_defaults")
          
          (role "kubernetes-apps/external_cloud_controller")
          (tags "external-cloud-controller")
          
          (role "kubernetes-apps/policy_controller")
          (tags "policy-controller")
          
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
