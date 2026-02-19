(playbook "kubespray/roles/network_plugin/cilium/tasks/apply.yml"
  (tasks
    (task "Check if Cilium Helm release exists (via cilium version)"
      (command (jinja "{{ bin_dir }}") "/cilium version")
      (register "cilium_release_info")
      (when "inventory_hostname == groups['kube_control_plane'][0]")
      (failed_when "false")
      (changed_when "false"))
    (task "Set action to install or upgrade"
      (set_fact 
        (cilium_action (jinja "{{ 'install' if ('release: not found' in cilium_release_info.stderr | default('') or 'release: not found' in cilium_release_info.stdout | default('')) else 'upgrade' }}"))))
    (task "Cilium | Install"
      (command (jinja "{{ bin_dir }}") "/cilium " (jinja "{{ cilium_action }}") " --version " (jinja "{{ cilium_version }}") " -f " (jinja "{{ kube_config_dir }}") "/cilium-values.yaml -f " (jinja "{{ kube_config_dir }}") "/cilium-extra-values.yaml " (jinja "{{ cilium_install_extra_flags }}"))
      (environment (jinja "{{ proxy_env }}"))
      (when "inventory_hostname == groups['kube_control_plane'][0]"))
    (task "Cilium | Wait for pods to run"
      (command (jinja "{{ kubectl }}") " -n kube-system get pods -l k8s-app=cilium -o jsonpath='{.items[?(@.status.containerStatuses[0].ready==false)].metadata.name}'")
      (register "pods_not_ready")
      (until "pods_not_ready.stdout.find(\"cilium\")==-1")
      (retries (jinja "{{ cilium_rolling_restart_wait_retries_count | int }}"))
      (delay (jinja "{{ cilium_rolling_restart_wait_retries_delay_seconds | int }}"))
      (failed_when "false")
      (when "inventory_hostname == groups['kube_control_plane'][0]"))
    (task "Cilium | Wait for CiliumLoadBalancerIPPool CRD to be present"
      (command (jinja "{{ kubectl }}") " wait --for condition=established --timeout=60s crd/ciliumloadbalancerippools.cilium.io")
      (register "cillium_lbippool_crd_ready")
      (retries (jinja "{{ cilium_rolling_restart_wait_retries_count | int }}"))
      (delay (jinja "{{ cilium_rolling_restart_wait_retries_delay_seconds | int }}"))
      (failed_when "false")
      (when (list
          "inventory_hostname == groups['kube_control_plane'][0]"
          "cilium_loadbalancer_ip_pools is defined and (cilium_loadbalancer_ip_pools|length>0)")))
    (task "Cilium | Create CiliumLoadBalancerIPPool manifests"
      (template 
        (src (jinja "{{ item.name }}") "/" (jinja "{{ item.file }}") ".j2")
        (dest (jinja "{{ kube_config_dir }}") "/" (jinja "{{ item.name }}") "-" (jinja "{{ item.file }}"))
        (mode "0644"))
      (with_items (list
          
          (name "cilium")
          (file "cilium-loadbalancer-ip-pool.yml")
          (type "CiliumLoadBalancerIPPool")))
      (when (list
          "inventory_hostname == groups['kube_control_plane'][0]"
          "cillium_lbippool_crd_ready is defined and cillium_lbippool_crd_ready.rc is defined and cillium_lbippool_crd_ready.rc == 0"
          "cilium_loadbalancer_ip_pools is defined and (cilium_loadbalancer_ip_pools|length>0)")))
    (task "Cilium | Apply CiliumLoadBalancerIPPool from cilium_loadbalancer_ip_pools"
      (kube 
        (name (jinja "{{ item.name }}"))
        (kubectl (jinja "{{ bin_dir }}") "/kubectl")
        (resource (jinja "{{ item.type }}"))
        (filename (jinja "{{ kube_config_dir }}") "/" (jinja "{{ item.name }}") "-" (jinja "{{ item.file }}"))
        (state "latest"))
      (loop (list
          
          (name "cilium")
          (file "cilium-loadbalancer-ip-pool.yml")
          (type "CiliumLoadBalancerIPPool")))
      (when (list
          "inventory_hostname == groups['kube_control_plane'][0]"
          "cillium_lbippool_crd_ready is defined and cillium_lbippool_crd_ready.rc is defined and cillium_lbippool_crd_ready.rc == 0"
          "cilium_loadbalancer_ip_pools is defined and (cilium_loadbalancer_ip_pools|length>0)")))
    (task "Cilium | Wait for CiliumBGPPeeringPolicy CRD to be present"
      (command (jinja "{{ kubectl }}") " wait --for condition=established --timeout=60s crd/ciliumbgppeeringpolicies.cilium.io")
      (register "cillium_bgpppolicy_crd_ready")
      (retries (jinja "{{ cilium_rolling_restart_wait_retries_count | int }}"))
      (delay (jinja "{{ cilium_rolling_restart_wait_retries_delay_seconds | int }}"))
      (failed_when "false")
      (when (list
          "inventory_hostname == groups['kube_control_plane'][0]"
          "cilium_bgp_peering_policies is defined and (cilium_bgp_peering_policies|length>0)")))
    (task "Cilium | Create CiliumBGPPeeringPolicy manifests"
      (template 
        (src (jinja "{{ item.name }}") "/" (jinja "{{ item.file }}") ".j2")
        (dest (jinja "{{ kube_config_dir }}") "/" (jinja "{{ item.name }}") "-" (jinja "{{ item.file }}"))
        (mode "0644"))
      (with_items (list
          
          (name "cilium")
          (file "cilium-bgp-peering-policy.yml")
          (type "CiliumBGPPeeringPolicy")))
      (when (list
          "inventory_hostname == groups['kube_control_plane'][0]"
          "cillium_bgpppolicy_crd_ready is defined and cillium_bgpppolicy_crd_ready.rc is defined and cillium_bgpppolicy_crd_ready.rc == 0"
          "cilium_bgp_peering_policies is defined and (cilium_bgp_peering_policies|length>0)")))
    (task "Cilium | Apply CiliumBGPPeeringPolicy from cilium_bgp_peering_policies"
      (kube 
        (name (jinja "{{ item.name }}"))
        (kubectl (jinja "{{ bin_dir }}") "/kubectl")
        (resource (jinja "{{ item.type }}"))
        (filename (jinja "{{ kube_config_dir }}") "/" (jinja "{{ item.name }}") "-" (jinja "{{ item.file }}"))
        (state "latest"))
      (loop (list
          
          (name "cilium")
          (file "cilium-bgp-peering-policy.yml")
          (type "CiliumBGPPeeringPolicy")))
      (when (list
          "inventory_hostname == groups['kube_control_plane'][0]"
          "cillium_bgpppolicy_crd_ready is defined and cillium_bgpppolicy_crd_ready.rc is defined and cillium_bgpppolicy_crd_ready.rc == 0"
          "cilium_bgp_peering_policies is defined and (cilium_bgp_peering_policies|length>0)")))
    (task "Cilium | Wait for CiliumBGPClusterConfig CRD to be present"
      (command (jinja "{{ kubectl }}") " wait --for condition=established --timeout=60s crd/ciliumbgpclusterconfigs.cilium.io")
      (register "cillium_bgpcconfig_crd_ready")
      (retries (jinja "{{ cilium_rolling_restart_wait_retries_count | int }}"))
      (delay (jinja "{{ cilium_rolling_restart_wait_retries_delay_seconds | int }}"))
      (failed_when "false")
      (when (list
          "inventory_hostname == groups['kube_control_plane'][0]"
          "cilium_bgp_cluster_configs is defined and (cilium_bgp_cluster_configs|length>0)")))
    (task "Cilium | Create CiliumBGPClusterConfig manifests"
      (template 
        (src (jinja "{{ item.name }}") "/" (jinja "{{ item.file }}") ".j2")
        (dest (jinja "{{ kube_config_dir }}") "/" (jinja "{{ item.name }}") "-" (jinja "{{ item.file }}"))
        (mode "0644"))
      (with_items (list
          
          (name "cilium")
          (file "cilium-bgp-cluster-config.yml")
          (type "CiliumBGPClusterConfig")))
      (when (list
          "inventory_hostname == groups['kube_control_plane'][0]"
          "cillium_bgpcconfig_crd_ready is defined and cillium_bgpcconfig_crd_ready.rc is defined and cillium_bgpcconfig_crd_ready.rc == 0"
          "cilium_bgp_cluster_configs is defined and (cilium_bgp_cluster_configs|length>0)")))
    (task "Cilium | Apply CiliumBGPClusterConfig from cilium_bgp_cluster_configs"
      (kube 
        (name (jinja "{{ item.name }}"))
        (kubectl (jinja "{{ bin_dir }}") "/kubectl")
        (resource (jinja "{{ item.type }}"))
        (filename (jinja "{{ kube_config_dir }}") "/" (jinja "{{ item.name }}") "-" (jinja "{{ item.file }}"))
        (state "latest"))
      (loop (list
          
          (name "cilium")
          (file "cilium-bgp-cluster-config.yml")
          (type "CiliumBGPClusterConfig")))
      (when (list
          "inventory_hostname == groups['kube_control_plane'][0]"
          "cillium_bgpcconfig_crd_ready is defined and cillium_bgpcconfig_crd_ready.rc is defined and cillium_bgpcconfig_crd_ready.rc == 0"
          "cilium_bgp_cluster_configs is defined and (cilium_bgp_cluster_configs|length>0)")))
    (task "Cilium | Wait for CiliumBGPPeerConfig CRD to be present"
      (command (jinja "{{ kubectl }}") " wait --for condition=established --timeout=60s crd/ciliumbgppeerconfigs.cilium.io")
      (register "cillium_bgppconfig_crd_ready")
      (retries (jinja "{{ cilium_rolling_restart_wait_retries_count | int }}"))
      (delay (jinja "{{ cilium_rolling_restart_wait_retries_delay_seconds | int }}"))
      (failed_when "false")
      (when (list
          "inventory_hostname == groups['kube_control_plane'][0]"
          "cilium_bgp_peer_configs is defined and (cilium_bgp_peer_configs|length>0)")))
    (task "Cilium | Create CiliumBGPPeerConfig manifests"
      (template 
        (src (jinja "{{ item.name }}") "/" (jinja "{{ item.file }}") ".j2")
        (dest (jinja "{{ kube_config_dir }}") "/" (jinja "{{ item.name }}") "-" (jinja "{{ item.file }}"))
        (mode "0644"))
      (with_items (list
          
          (name "cilium")
          (file "cilium-bgp-peer-config.yml")
          (type "CiliumBGPPeerConfig")))
      (when (list
          "inventory_hostname == groups['kube_control_plane'][0]"
          "cillium_bgppconfig_crd_ready is defined and cillium_bgppconfig_crd_ready.rc is defined and cillium_bgppconfig_crd_ready.rc == 0"
          "cilium_bgp_peer_configs is defined and (cilium_bgp_peer_configs|length>0)")))
    (task "Cilium | Apply CiliumBGPPeerConfig from cilium_bgp_peer_configs"
      (kube 
        (name (jinja "{{ item.name }}"))
        (kubectl (jinja "{{ bin_dir }}") "/kubectl")
        (resource (jinja "{{ item.type }}"))
        (filename (jinja "{{ kube_config_dir }}") "/" (jinja "{{ item.name }}") "-" (jinja "{{ item.file }}"))
        (state "latest"))
      (loop (list
          
          (name "cilium")
          (file "cilium-bgp-peer-config.yml")
          (type "CiliumBGPPeerConfig")))
      (when (list
          "inventory_hostname == groups['kube_control_plane'][0]"
          "cillium_bgppconfig_crd_ready is defined and cillium_bgppconfig_crd_ready.rc is defined and cillium_bgppconfig_crd_ready.rc == 0"
          "cilium_bgp_peer_configs is defined and (cilium_bgp_peer_configs|length>0)")))
    (task "Cilium | Wait for CiliumBGPAdvertisement CRD to be present"
      (command (jinja "{{ kubectl }}") " wait --for condition=established --timeout=60s crd/ciliumbgpadvertisements.cilium.io")
      (register "cillium_bgpadvert_crd_ready")
      (retries (jinja "{{ cilium_rolling_restart_wait_retries_count | int }}"))
      (delay (jinja "{{ cilium_rolling_restart_wait_retries_delay_seconds | int }}"))
      (failed_when "false")
      (when (list
          "inventory_hostname == groups['kube_control_plane'][0]"
          "cilium_bgp_advertisements is defined and (cilium_bgp_advertisements|length>0)")))
    (task "Cilium | Create CiliumBGPAdvertisement manifests"
      (template 
        (src (jinja "{{ item.name }}") "/" (jinja "{{ item.file }}") ".j2")
        (dest (jinja "{{ kube_config_dir }}") "/" (jinja "{{ item.name }}") "-" (jinja "{{ item.file }}"))
        (mode "0644"))
      (with_items (list
          
          (name "cilium")
          (file "cilium-bgp-advertisement.yml")
          (type "CiliumBGPAdvertisement")))
      (when (list
          "inventory_hostname == groups['kube_control_plane'][0]"
          "cillium_bgpadvert_crd_ready is defined and cillium_bgpadvert_crd_ready.rc is defined and cillium_bgpadvert_crd_ready.rc == 0"
          "cilium_bgp_advertisements is defined and (cilium_bgp_advertisements|length>0)")))
    (task "Cilium | Apply CiliumBGPAdvertisement from cilium_bgp_advertisements"
      (kube 
        (name (jinja "{{ item.name }}"))
        (kubectl (jinja "{{ bin_dir }}") "/kubectl")
        (resource (jinja "{{ item.type }}"))
        (filename (jinja "{{ kube_config_dir }}") "/" (jinja "{{ item.name }}") "-" (jinja "{{ item.file }}"))
        (state "latest"))
      (loop (list
          
          (name "cilium")
          (file "cilium-bgp-advertisement.yml")
          (type "CiliumBGPAdvertisement")))
      (when (list
          "inventory_hostname == groups['kube_control_plane'][0]"
          "cillium_bgpadvert_crd_ready is defined and cillium_bgpadvert_crd_ready.rc is defined and cillium_bgpadvert_crd_ready.rc == 0"
          "cilium_bgp_advertisements is defined and (cilium_bgp_advertisements|length>0)")))
    (task "Cilium | Wait for CiliumBGPNodeConfigOverride CRD to be present"
      (command (jinja "{{ kubectl }}") " wait --for condition=established --timeout=60s crd/ciliumbgpnodeconfigoverrides.cilium.io")
      (register "cilium_bgp_node_config_crd_ready")
      (retries (jinja "{{ cilium_rolling_restart_wait_retries_count | int }}"))
      (delay (jinja "{{ cilium_rolling_restart_wait_retries_delay_seconds | int }}"))
      (failed_when "false")
      (when (list
          "inventory_hostname == groups['kube_control_plane'][0]"
          "cilium_bgp_advertisements is defined and (cilium_bgp_advertisements|length>0)")))
    (task "Cilium | Create CiliumBGPNodeConfigOverride manifests"
      (template 
        (src (jinja "{{ item.name }}") "/" (jinja "{{ item.file }}") ".j2")
        (dest (jinja "{{ kube_config_dir }}") "/" (jinja "{{ item.name }}") "-" (jinja "{{ item.file }}"))
        (mode "0644"))
      (with_items (list
          
          (name "cilium")
          (file "cilium-bgp-node-config-override.yml")
          (type "CiliumBGPNodeConfigOverride")))
      (when (list
          "inventory_hostname == groups['kube_control_plane'][0]"
          "cilium_bgp_node_config_crd_ready is defined and cilium_bgp_node_config_crd_ready.rc is defined and cilium_bgp_node_config_crd_ready.rc == 0"
          "cilium_bgp_node_config_overrides is defined and (cilium_bgp_node_config_overrides|length>0)")))
    (task "Cilium | Apply CiliumBGPNodeConfigOverride from cilium_bgp_node_config_overrides"
      (kube 
        (name (jinja "{{ item.name }}"))
        (kubectl (jinja "{{ bin_dir }}") "/kubectl")
        (resource (jinja "{{ item.type }}"))
        (filename (jinja "{{ kube_config_dir }}") "/" (jinja "{{ item.name }}") "-" (jinja "{{ item.file }}"))
        (state "latest"))
      (loop (list
          
          (name "cilium")
          (file "cilium-bgp-node-config-override.yml")
          (type "CiliumBGPNodeConfigOverride")))
      (when (list
          "inventory_hostname == groups['kube_control_plane'][0]"
          "cilium_bgp_node_config_crd_ready is defined and cilium_bgp_node_config_crd_ready.rc is defined and cilium_bgp_node_config_crd_ready.rc == 0"
          "cilium_bgp_node_config_overrides is defined and (cilium_bgp_node_config_overrides|length>0)")))))
