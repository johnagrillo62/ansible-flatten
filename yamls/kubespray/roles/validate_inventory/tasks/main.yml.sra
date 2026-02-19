(playbook "kubespray/roles/validate_inventory/tasks/main.yml"
  (tasks
    (task "Fail if removed variables are used"
      (assert 
        (that "removed_vars_found | length == 0")
        (fail_msg "Removed variables present: " (jinja "{{ removed_vars_found | join(', ') }}")))
      (vars 
        (removed_vars (list
            "kubelet_static_pod_path"))
        (removed_vars_found (jinja "{{ query('varnames', '^' + (removed_vars | join('|')) + '$') }}")))
      (run_once "true"))
    (task "Stop if kube_control_plane group is empty"
      (assert 
        (that "groups.get( 'kube_control_plane' )"))
      (run_once "true")
      (when "not ignore_assert_errors"))
    (task "Stop if etcd group is empty in external etcd mode"
      (assert 
        (that "groups.get('etcd') or etcd_deployment_type == 'kubeadm'")
        (fail_msg "Group 'etcd' cannot be empty in external etcd mode"))
      (run_once "true")
      (when (list
          "not ignore_assert_errors")))
    (task "Warn if `kube_network_plugin` is `none`"
      (debug 
        (msg "\"WARNING! => `kube_network_plugin` is set to `none`. The network configuration will be skipped.
The cluster won't be ready to use, we recommend to select one of the available plugins\"
"))
      (when (list
          "kube_network_plugin == 'none'")))
    (task "Stop if unsupported version of Kubernetes"
      (assert 
        (that "kube_version is version(kube_version_min_required, '>=')")
        (msg "The current release of Kubespray only support newer version of Kubernetes than " (jinja "{{ kube_version_min_required }}") " - You are trying to apply " (jinja "{{ kube_version }}")))
      (when "not ignore_assert_errors"))
    (task "Stop if known booleans are set as strings (Use JSON format on CLI: -e \"{'key': true }\")"
      (assert 
        (that (list
            "download_run_once | type_debug == 'bool'"
            "deploy_netchecker | type_debug == 'bool'"
            "download_always_pull | type_debug == 'bool'"
            "helm_enabled | type_debug == 'bool'"
            "openstack_lbaas_enabled | type_debug == 'bool'")))
      (run_once "true")
      (when "not ignore_assert_errors"))
    (task "Stop if even number of etcd hosts"
      (assert 
        (that "groups.get('etcd', groups.kube_control_plane) | length is not divisibleby 2"))
      (run_once "true")
      (when (list
          "not ignore_assert_errors")))
    (task "Guarantee that enough network address space is available for all pods"
      (assert 
        (that (jinja "{{ (kubelet_max_pods | default(110)) | int <= (2 ** (32 - kube_network_node_prefix | int)) - 2 }}"))
        (msg "Do not schedule more pods on a node than inet addresses are available."))
      (when (list
          "not ignore_assert_errors"
          "('k8s_cluster' in group_names)"
          "kube_network_plugin not in ['calico', 'none']"
          "ipv4_stack | bool")))
    (task "Check cloud_provider value"
      (assert 
        (that "cloud_provider == 'external'"))
      (when (list
          "cloud_provider"
          "not ignore_assert_errors")))
    (task "Check external_cloud_provider value"
      (assert 
        (that "external_cloud_provider in ['hcloud', 'huaweicloud', 'oci', 'openstack', 'vsphere', 'manual']"))
      (when (list
          "cloud_provider == 'external'"
          "not ignore_assert_errors")))
    (task "Check that kube_service_addresses is a network range"
      (assert 
        (that (list
            "kube_service_addresses | ansible.utils.ipaddr('net')"))
        (msg "kube_service_addresses = '" (jinja "{{ kube_service_addresses }}") "' is not a valid network range"))
      (run_once "true")
      (when "ipv4_stack | bool"))
    (task "Check that kube_pods_subnet is a network range"
      (assert 
        (that (list
            "kube_pods_subnet | ansible.utils.ipaddr('net')"))
        (msg "kube_pods_subnet = '" (jinja "{{ kube_pods_subnet }}") "' is not a valid network range"))
      (run_once "true")
      (when "ipv4_stack | bool"))
    (task "Check that kube_pods_subnet does not collide with kube_service_addresses"
      (assert 
        (that (list
            "kube_pods_subnet | ansible.utils.ipaddr(kube_service_addresses) | string == 'None'"))
        (msg "kube_pods_subnet cannot be the same network segment as kube_service_addresses"))
      (run_once "true")
      (when "ipv4_stack | bool"))
    (task "Check that ipv4 IP range is enough for the nodes"
      (assert 
        (that (list
            "2 ** (kube_network_node_prefix - kube_pods_subnet | ansible.utils.ipaddr('prefix')) >= groups['k8s_cluster'] | length"))
        (msg "Not enough ipv4 IPs are available for the desired node count."))
      (when (list
          "ipv4_stack | bool"
          "kube_network_plugin != 'calico'"))
      (run_once "true"))
    (task "Check that kube_service_addresses_ipv6 is a network range"
      (assert 
        (that (list
            "kube_service_addresses_ipv6 | ansible.utils.ipaddr('net')"))
        (msg "kube_service_addresses_ipv6 = '" (jinja "{{ kube_service_addresses_ipv6 }}") "' is not a valid network range"))
      (run_once "true")
      (when "ipv6_stack | bool"))
    (task "Check that kube_pods_subnet_ipv6 is a network range"
      (assert 
        (that (list
            "kube_pods_subnet_ipv6 | ansible.utils.ipaddr('net')"))
        (msg "kube_pods_subnet_ipv6 = '" (jinja "{{ kube_pods_subnet_ipv6 }}") "' is not a valid network range"))
      (run_once "true")
      (when "ipv6_stack | bool"))
    (task "Check that kube_pods_subnet_ipv6 does not collide with kube_service_addresses_ipv6"
      (assert 
        (that (list
            "kube_pods_subnet_ipv6 | ansible.utils.ipaddr(kube_service_addresses_ipv6) | string == 'None'"))
        (msg "kube_pods_subnet_ipv6 cannot be the same network segment as kube_service_addresses_ipv6"))
      (run_once "true")
      (when "ipv6_stack | bool"))
    (task "Check that ipv6 IP range is enough for the nodes"
      (assert 
        (that (list
            "2 ** (kube_network_node_prefix_ipv6 - kube_pods_subnet_ipv6 | ansible.utils.ipaddr('prefix')) >= groups['k8s_cluster'] | length"))
        (msg "Not enough ipv6 IPs are available for the desired node count."))
      (when (list
          "ipv6_stack | bool"
          "kube_network_plugin != 'calico'"))
      (run_once "true"))
    (task "Stop if unsupported options selected"
      (assert 
        (that (list
            "kube_network_plugin in ['calico', 'flannel', 'cloud', 'cilium', 'cni', 'kube-ovn', 'kube-router', 'macvlan', 'custom_cni', 'none']"
            "dns_mode in ['coredns', 'coredns_dual', 'manual', 'none']"
            "kube_proxy_mode in ['iptables', 'ipvs', 'nftables']"
            "cert_management in ['script', 'none']"
            "resolvconf_mode in ['docker_dns', 'host_resolvconf', 'none']"
            "etcd_deployment_type in ['host', 'docker', 'kubeadm']"
            "etcd_deployment_type in ['host', 'kubeadm'] or container_manager == 'docker'"
            "container_manager in ['docker', 'crio', 'containerd']"))
        (msg "The selected choice is not supported"))
      (run_once "true"))
    (task "Warn if `enable_dual_stack_networks` is set"
      (debug 
        (msg "WARNING! => `enable_dual_stack_networks` deprecation. Please switch to using ipv4_stack and ipv6_stack."))
      (when (list
          "enable_dual_stack_networks is defined")))
    (task "Stop if download_localhost is enabled but download_run_once is not"
      (assert 
        (that "download_run_once")
        (msg "download_localhost requires enable download_run_once"))
      (when "download_localhost"))
    (task "Stop if kata_containers_enabled is enabled when container_manager is docker"
      (assert 
        (that "container_manager != 'docker'")
        (msg "kata_containers_enabled support only for containerd and crio-o. See https://github.com/kata-containers/documentation/blob/1.11.4/how-to/run-kata-with-k8s.md#install-a-cri-implementation for details"))
      (when "kata_containers_enabled"))
    (task "Stop if gvisor_enabled is enabled when container_manager is not containerd"
      (assert 
        (that "container_manager == 'containerd'")
        (msg "gvisor_enabled support only compatible with containerd. See https://github.com/kubernetes-sigs/kubespray/issues/7650 for details"))
      (when "gvisor_enabled"))
    (task "Ensure minimum containerd version"
      (assert 
        (that "containerd_version is version(containerd_min_version_required, '>=')")
        (msg "containerd_version is too low. Minimum version " (jinja "{{ containerd_min_version_required }}")))
      (run_once "true")
      (when (list
          "containerd_version not in ['latest', 'edge', 'stable']"
          "container_manager == 'containerd'")))
    (task "Stop if auto_renew_certificates is enabled when certificates are managed externally (kube_external_ca_mode is true)"
      (assert 
        (that "not auto_renew_certificates")
        (msg "Variable auto_renew_certificates must be disabled when CA are managed externally:  kube_external_ca_mode = true"))
      (when (list
          "kube_external_ca_mode"
          "not ignore_assert_errors")))))
