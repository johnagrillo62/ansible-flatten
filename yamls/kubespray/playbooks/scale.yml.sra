(playbook "kubespray/playbooks/scale.yml"
  (tasks
    (task "Common tasks for every playbooks"
      (import_playbook "boilerplate.yml"))
    (task "Gather facts"
      (import_playbook "internal_facts.yml"))
    (task "Install etcd"
      (import_playbook "install_etcd.yml")
      (vars 
        (etcd_cluster_setup "false")
        (etcd_events_cluster_setup "false")))
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
    (task "Target only workers to get kubelet installed and checking in on any new nodes(engine)"
      (hosts "kube_node")
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
          (when "not skip_downloads")
          
          (role "etcd")
          (tags "etcd")
          (vars 
            (etcd_cluster_setup "false"))
          (when (list
              "etcd_deployment_type != \"kubeadm\""
              "kube_network_plugin in [\"calico\", \"flannel\", \"canal\", \"cilium\"] or cilium_deploy_additionally | default(false) | bool"
              "kube_network_plugin != \"calico\" or calico_datastore == \"etcd\""))))
      (any_errors_fatal (jinja "{{ any_errors_fatal | default(true) }}"))
      (environment (jinja "{{ proxy_disable_env }}")))
    (task "Target only workers to get kubelet installed and checking in on any new nodes(node)"
      (hosts "kube_node")
      (gather_facts "false")
      (roles (list
          
          (role "kubespray_defaults")
          
          (role "kubernetes/node")
          (tags "node")))
      (any_errors_fatal (jinja "{{ any_errors_fatal | default(true) }}"))
      (environment (jinja "{{ proxy_disable_env }}")))
    (task "Upload control plane certs and retrieve encryption key"
      (hosts "kube_control_plane | first")
      (gather_facts "false")
      (roles (list
          
          (role "kubespray_defaults")))
      (tasks (list
          
          (name "Upload control plane certificates")
          (command (jinja "{{ bin_dir }}") "/kubeadm init phase --config " (jinja "{{ kube_config_dir }}") "/kubeadm-config.yaml upload-certs --upload-certs")
          (environment (jinja "{{ proxy_disable_env }}"))
          (register "kubeadm_upload_cert")
          (changed_when "false")
          
          (name "Set fact 'kubeadm_certificate_key' for later use")
          (set_fact 
            (kubeadm_certificate_key (jinja "{{ kubeadm_upload_cert.stdout_lines[-1] | trim }}")))
          (when "kubeadm_certificate_key is not defined")))
      (environment (jinja "{{ proxy_disable_env }}"))
      (tags "kubeadm"))
    (task "Target only workers to get kubelet installed and checking in on any new nodes(network)"
      (hosts "kube_node")
      (gather_facts "false")
      (roles (list
          
          (role "kubespray_defaults")
          
          (role "kubernetes/kubeadm")
          (tags "kubeadm")
          
          (role "kubernetes/node-label")
          (tags "node-label")
          
          (role "kubernetes/node-taint")
          (tags "node-taint")
          
          (role "network_plugin")
          (tags "network")))
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
