(playbook "kubespray/roles/network_plugin/calico/tasks/install.yml"
  (tasks
    (task "Calico | Install Wireguard packages"
      (package 
        (name (jinja "{{ item }}"))
        (state "present"))
      (with_items (jinja "{{ calico_wireguard_packages }}"))
      (register "calico_package_install")
      (until "calico_package_install is succeeded")
      (retries "4")
      (when "calico_wireguard_enabled"))
    (task "Calico | Copy calicoctl binary from download dir"
      (copy 
        (src (jinja "{{ downloads.calicoctl.dest }}"))
        (dest (jinja "{{ bin_dir }}") "/calicoctl")
        (mode "0755")
        (remote_src "true")))
    (task "Calico | Create calico certs directory"
      (file 
        (dest (jinja "{{ calico_cert_dir }}"))
        (state "directory")
        (mode "0750")
        (owner "root")
        (group "root"))
      (when "calico_datastore == \"etcd\""))
    (task "Calico | Link etcd certificates for calico-node"
      (file 
        (src (jinja "{{ etcd_cert_dir }}") "/" (jinja "{{ item.s }}"))
        (dest (jinja "{{ calico_cert_dir }}") "/" (jinja "{{ item.d }}"))
        (state "hard")
        (mode "0640")
        (force "true"))
      (with_items (list
          
          (s (jinja "{{ kube_etcd_cacert_file }}"))
          (d "ca_cert.crt")
          
          (s (jinja "{{ kube_etcd_cert_file }}"))
          (d "cert.crt")
          
          (s (jinja "{{ kube_etcd_key_file }}"))
          (d "key.pem")))
      (when "calico_datastore == \"etcd\""))
    (task "Calico | Generate typha certs"
      (include_tasks "typha_certs.yml")
      (when (list
          "typha_secure"
          "inventory_hostname == groups['kube_control_plane'][0]")))
    (task "Calico | Generate apiserver certs"
      (include_tasks "calico_apiserver_certs.yml")
      (when (list
          "calico_apiserver_enabled"
          "inventory_hostname == groups['kube_control_plane'][0]")))
    (task "Calico | Install calicoctl wrapper script"
      (template 
        (src "calicoctl." (jinja "{{ calico_datastore }}") ".sh.j2")
        (dest (jinja "{{ bin_dir }}") "/calicoctl.sh")
        (mode "0755")
        (owner "root")
        (group "root")))
    (task "Calico | wait for etcd"
      (uri 
        (url (jinja "{{ etcd_access_addresses.split(',') | first }}") "/health")
        (validate_certs "false")
        (client_cert (jinja "{{ calico_cert_dir }}") "/cert.crt")
        (client_key (jinja "{{ calico_cert_dir }}") "/key.pem"))
      (register "result")
      (until "result.status == 200 or result.status == 401")
      (retries "10")
      (delay "5")
      (run_once "true")
      (when "calico_datastore == \"etcd\""))
    (task "Calico | Check if calico network pool has already been configured"
      (shell (jinja "{{ bin_dir }}") "/calicoctl.sh get ippool | grep -w \"" (jinja "{{ calico_pool_cidr | default(kube_pods_subnet) }}") "\" | wc -l
")
      (args 
        (executable "/bin/bash"))
      (register "calico_conf")
      (retries "4")
      (until "calico_conf.rc == 0")
      (delay (jinja "{{ retry_stagger | random + 3 }}"))
      (changed_when "false")
      (when (list
          "inventory_hostname == groups['kube_control_plane'][0]"
          "ipv4_stack | bool")))
    (task "Calico | Ensure that calico_pool_cidr is within kube_pods_subnet when defined"
      (assert 
        (that "[calico_pool_cidr] | ansible.utils.ipaddr(kube_pods_subnet) | length == 1")
        (msg (jinja "{{ calico_pool_cidr }}") " is not within or equal to " (jinja "{{ kube_pods_subnet }}")))
      (when (list
          "inventory_hostname == groups['kube_control_plane'][0]"
          "ipv4_stack | bool"
          "calico_pool_cidr is defined"
          "calico_conf.stdout == \"0\"")))
    (task "Calico | Check if calico IPv6 network pool has already been configured"
      (shell (jinja "{{ bin_dir }}") "/calicoctl.sh get ippool | grep -w \"" (jinja "{{ calico_pool_cidr_ipv6 | default(kube_pods_subnet_ipv6) }}") "\" | wc -l
")
      (args 
        (executable "/bin/bash"))
      (register "calico_conf_ipv6")
      (retries "4")
      (until "calico_conf_ipv6.rc == 0")
      (delay (jinja "{{ retry_stagger | random + 3 }}"))
      (changed_when "false")
      (when (list
          "inventory_hostname == groups['kube_control_plane'][0]"
          "ipv6_stack")))
    (task "Calico | Ensure that calico_pool_cidr_ipv6 is within kube_pods_subnet_ipv6 when defined"
      (assert 
        (that "[calico_pool_cidr_ipv6] | ansible.utils.ipaddr(kube_pods_subnet_ipv6) | length == 1")
        (msg (jinja "{{ calico_pool_cidr_ipv6 }}") " is not within or equal to " (jinja "{{ kube_pods_subnet_ipv6 }}")))
      (when (list
          "inventory_hostname == groups['kube_control_plane'][0]"
          "ipv6_stack | bool"
          "calico_conf_ipv6.stdout is defined and calico_conf_ipv6.stdout == \"0\""
          "calico_pool_cidr_ipv6 is defined")))
    (task "Calico | kdd specific configuration"
      (block (list
          
          (name "Calico | Create calico manifests for kdd")
          (copy 
            (src (jinja "{{ local_release_dir }}") "/calico-" (jinja "{{ calico_version }}") "-kdd-crds/crds.yaml")
            (dest (jinja "{{ kube_config_dir }}") "/kdd-crds.yml")
            (mode "0644")
            (remote_src "true"))
          
          (name "Calico | Create Calico Kubernetes datastore resources")
          (kube 
            (kubectl (jinja "{{ bin_dir }}") "/kubectl")
            (filename (jinja "{{ kube_config_dir }}") "/kdd-crds.yml")
            (state "latest"))
          (register "kubectl_result")
          (until "kubectl_result is succeeded")
          (retries "5")
          (when (list
              "inventory_hostname == groups['kube_control_plane'][0]"))))
      (when (list
          "('kube_control_plane' in group_names)"
          "calico_datastore == \"kdd\"")))
    (task "Calico | Configure Felix"
      (block (list
          
          (name "Calico | Get existing FelixConfiguration")
          (command (jinja "{{ bin_dir }}") "/calicoctl.sh get felixconfig default -o json")
          (register "_felix_cmd")
          (ignore_errors "true")
          (changed_when "false")
          
          (name "Calico | Set kubespray FelixConfiguration")
          (set_fact 
            (_felix_config "{
  \"kind\": \"FelixConfiguration\",
  \"apiVersion\": \"projectcalico.org/v3\",
  \"metadata\": {
    \"name\": \"default\",
  },
  \"spec\": {
    \"ipipEnabled\": " (jinja "{{ calico_ipip_mode != 'Never' }}") ",
    \"reportingInterval\": \"" (jinja "{{ calico_felix_reporting_interval }}") "\",
    \"bpfLogLevel\": \"" (jinja "{{ calico_bpf_log_level }}") "\",
    \"bpfEnabled\": " (jinja "{{ calico_bpf_enabled | bool }}") ",
    \"bpfExternalServiceMode\": \"" (jinja "{{ calico_bpf_service_mode }}") "\",
    \"wireguardEnabled\": " (jinja "{{ calico_wireguard_enabled | bool }}") ",
    \"logSeverityScreen\": \"" (jinja "{{ calico_felix_log_severity_screen }}") "\",
    \"vxlanEnabled\": " (jinja "{{ calico_vxlan_mode != 'Never' }}") ",
    \"featureDetectOverride\": \"" (jinja "{{ calico_feature_detect_override }}") "\",
    \"floatingIPs\": \"" (jinja "{{ calico_felix_floating_ips }}") "\"
  }
}
"))
          
          (name "Calico | Process FelixConfiguration")
          (set_fact 
            (_felix_config (jinja "{{ _felix_cmd.stdout | from_json | combine(_felix_config, recursive=True) }}")))
          (when (list
              "_felix_cmd is success"))
          
          (name "Calico | Configure calico FelixConfiguration")
          (command 
            (cmd (jinja "{{ bin_dir }}") "/calicoctl.sh apply -f -")
            (stdin (jinja "{{ _felix_config is string | ternary(_felix_config, _felix_config | to_json) }}")))
          (changed_when "false")))
      (when (list
          "inventory_hostname == groups['kube_control_plane'][0]")))
    (task "Calico | Configure Calico IP Pool"
      (block (list
          
          (name "Calico | Get existing calico network pool")
          (command (jinja "{{ bin_dir }}") "/calicoctl.sh get ippool " (jinja "{{ calico_pool_name }}") " -o json")
          (register "_calico_pool_cmd")
          (ignore_errors "true")
          (changed_when "false")
          
          (name "Calico | Set kubespray calico network pool")
          (set_fact 
            (_calico_pool "{
  \"kind\": \"IPPool\",
  \"apiVersion\": \"projectcalico.org/v3\",
  \"metadata\": {
    \"name\": \"" (jinja "{{ calico_pool_name }}") "\",
  },
  \"spec\": {
    \"blockSize\": " (jinja "{{ calico_pool_blocksize }}") ",
    \"cidr\": \"" (jinja "{{ calico_pool_cidr | default(kube_pods_subnet) }}") "\",
    \"ipipMode\": \"" (jinja "{{ calico_ipip_mode }}") "\",
    \"vxlanMode\": \"" (jinja "{{ calico_vxlan_mode }}") "\",
    \"natOutgoing\": " (jinja "{{ nat_outgoing | default(false) }}") "
  }
}
"))
          
          (name "Calico | Process calico network pool")
          (when (list
              "_calico_pool_cmd is success"))
          (block (list
              
              (name "Calico | Get current calico network pool blocksize")
              (set_fact 
                (_calico_blocksize "{
  \"spec\": {
    \"blockSize\": " (jinja "{{ (_calico_pool_cmd.stdout | from_json).spec.blockSize }}") "
  }
}
"))
              
              (name "Calico | Merge calico network pool")
              (set_fact 
                (_calico_pool (jinja "{{ _calico_pool_cmd.stdout | from_json | combine(_calico_pool, _calico_blocksize, recursive=True) }}")))))
          
          (name "Calico | Configure calico network pool")
          (command 
            (cmd (jinja "{{ bin_dir }}") "/calicoctl.sh apply -f -")
            (stdin (jinja "{{ _calico_pool is string | ternary(_calico_pool, _calico_pool | to_json) }}")))
          (changed_when "false")))
      (when (list
          "inventory_hostname == groups['kube_control_plane'][0]"
          "ipv4_stack | bool")))
    (task "Calico | Configure Calico IPv6 Pool"
      (block (list
          
          (name "Calico | Get existing calico ipv6 network pool")
          (command (jinja "{{ bin_dir }}") "/calicoctl.sh get ippool " (jinja "{{ calico_pool_name }}") "-ipv6 -o json")
          (register "_calico_pool_ipv6_cmd")
          (ignore_errors "true")
          (changed_when "false")
          
          (name "Calico | Set kubespray calico network pool")
          (set_fact 
            (_calico_pool_ipv6 "{
  \"kind\": \"IPPool\",
  \"apiVersion\": \"projectcalico.org/v3\",
  \"metadata\": {
    \"name\": \"" (jinja "{{ calico_pool_name }}") "-ipv6\",
  },
  \"spec\": {
    \"blockSize\": " (jinja "{{ calico_pool_blocksize_ipv6 }}") ",
    \"cidr\": \"" (jinja "{{ calico_pool_cidr_ipv6 | default(kube_pods_subnet_ipv6) }}") "\",
    \"ipipMode\": \"" (jinja "{{ calico_ipip_mode_ipv6 }}") "\",
    \"vxlanMode\": \"" (jinja "{{ calico_vxlan_mode_ipv6 }}") "\",
    \"natOutgoing\": " (jinja "{{ nat_outgoing_ipv6 | default(false) }}") "
  }
}
"))
          
          (name "Calico | Process calico ipv6 network pool")
          (when (list
              "_calico_pool_ipv6_cmd is success"))
          (block (list
              
              (name "Calico | Get current calico ipv6 network pool blocksize")
              (set_fact 
                (_calico_blocksize_ipv6 "{
  \"spec\": {
    \"blockSize\": " (jinja "{{ (_calico_pool_ipv6_cmd.stdout | from_json).spec.blockSize }}") "
  }
}
"))
              
              (name "Calico | Merge calico ipv6 network pool")
              (set_fact 
                (_calico_pool_ipv6 (jinja "{{ _calico_pool_ipv6_cmd.stdout | from_json | combine(_calico_pool_ipv6, _calico_blocksize_ipv6, recursive=True) }}")))))
          
          (name "Calico | Configure calico ipv6 network pool")
          (command 
            (cmd (jinja "{{ bin_dir }}") "/calicoctl.sh apply -f -")
            (stdin (jinja "{{ _calico_pool_ipv6 is string | ternary(_calico_pool_ipv6, _calico_pool_ipv6 | to_json) }}")))
          (changed_when "false")))
      (when (list
          "inventory_hostname == groups['kube_control_plane'][0]"
          "ipv6_stack | bool")))
    (task "Populate Service External IPs"
      (set_fact 
        (_service_external_ips (jinja "{{ _service_external_ips | default([]) + [{'cidr': item}] }}")))
      (with_items (jinja "{{ calico_advertise_service_external_ips }}"))
      (run_once "true"))
    (task "Populate Service LoadBalancer IPs"
      (set_fact 
        (_service_loadbalancer_ips (jinja "{{ _service_loadbalancer_ips | default([]) + [{'cidr': item}] }}")))
      (with_items (jinja "{{ calico_advertise_service_loadbalancer_ips }}"))
      (run_once "true"))
    (task "Determine nodeToNodeMesh needed state"
      (set_fact 
        (nodeToNodeMeshEnabled "false"))
      (when (list
          "peer_with_router | default(false) or peer_with_calico_rr | default(false)"
          "('k8s_cluster' in group_names)"))
      (run_once "true"))
    (task "Calico | Configure Calico BGP"
      (block (list
          
          (name "Calico | Get existing BGP Configuration")
          (command (jinja "{{ bin_dir }}") "/calicoctl.sh get bgpconfig default -o json")
          (register "_bgp_config_cmd")
          (ignore_errors "true")
          (changed_when "false")
          
          (name "Calico | Set kubespray BGP Configuration")
          (set_fact 
            (_bgp_config "{
  \"kind\": \"BGPConfiguration\",
  \"apiVersion\": \"projectcalico.org/v3\",
  \"metadata\": {
    \"name\": \"default\",
  },
  \"spec\": {
    \"listenPort\": " (jinja "{{ calico_bgp_listen_port }}") ",
    \"logSeverityScreen\": \"Info\",
    " (jinja "{% if not calico_no_global_as_num | default(false) %}") "\"asNumber\": " (jinja "{{ global_as_num }}") "," (jinja "{% endif %}") "
    \"nodeToNodeMeshEnabled\": " (jinja "{{ nodeToNodeMeshEnabled | default('true') }}") " ,
    " (jinja "{% if calico_advertise_cluster_ips | default(false) %}") "
    \"serviceClusterIPs\":
      " (jinja "{%- if ipv4_stack and ipv6_stack-%}") "
      [{\"cidr\": \"" (jinja "{{ kube_service_addresses }}") "\", \"cidr\": \"" (jinja "{{ kube_service_addresses_ipv6 }}") "\"}],
      " (jinja "{%- elif ipv6_stack-%}") "
      [{\"cidr\": \"" (jinja "{{ kube_service_addresses_ipv6 }}") "\"}],
      " (jinja "{%- else -%}") "
      [{\"cidr\": \"" (jinja "{{ kube_service_addresses }}") "\"}],
      " (jinja "{%- endif -%}") "
    " (jinja "{% endif %}") "
    " (jinja "{% if calico_advertise_service_loadbalancer_ips | length > 0  %}") "\"serviceLoadBalancerIPs\": " (jinja "{{ _service_loadbalancer_ips }}") "," (jinja "{% endif %}") "
    \"serviceExternalIPs\": " (jinja "{{ _service_external_ips | default([]) }}") "
  }
}
"))
          
          (name "Calico | Process BGP Configuration")
          (set_fact 
            (_bgp_config (jinja "{{ _bgp_config_cmd.stdout | from_json | combine(_bgp_config, recursive=True) }}")))
          (when (list
              "_bgp_config_cmd is success"))
          
          (name "Calico | Set up BGP Configuration")
          (command 
            (cmd (jinja "{{ bin_dir }}") "/calicoctl.sh apply -f -")
            (stdin (jinja "{{ _bgp_config is string | ternary(_bgp_config, _bgp_config | to_json) }}")))
          (changed_when "false")))
      (when (list
          "inventory_hostname == groups['kube_control_plane'][0]")))
    (task "Calico | Create calico manifests"
      (template 
        (src (jinja "{{ item.file }}") ".j2")
        (dest (jinja "{{ kube_config_dir }}") "/" (jinja "{{ item.file }}"))
        (mode "0644"))
      (with_items (list
          
          (name "calico-config")
          (file "calico-config.yml")
          (type "cm")
          
          (name "calico-node")
          (file "calico-node.yml")
          (type "ds")
          
          (name "calico")
          (file "calico-node-sa.yml")
          (type "sa")
          
          (name "calico")
          (file "calico-cr.yml")
          (type "clusterrole")
          
          (name "calico")
          (file "calico-crb.yml")
          (type "clusterrolebinding")
          
          (name "kubernetes-services-endpoint")
          (file "kubernetes-services-endpoint.yml")
          (type "cm")))
      (register "calico_node_manifests")
      (when (list
          "('kube_control_plane' in group_names)"
          "rbac_enabled or item.type not in rbac_resources")))
    (task "Calico | Create calico manifests for typha"
      (template 
        (src (jinja "{{ item.file }}") ".j2")
        (dest (jinja "{{ kube_config_dir }}") "/" (jinja "{{ item.file }}"))
        (mode "0644"))
      (with_items (list
          
          (name "calico")
          (file "calico-typha.yml")
          (type "typha")))
      (register "calico_node_typha_manifest")
      (when (list
          "('kube_control_plane' in group_names)"
          "typha_enabled")))
    (task "Calico | get calico apiserver caBundle"
      (command (jinja "{{ bin_dir }}") "/kubectl get secret -n calico-apiserver calico-apiserver-certs -o jsonpath='{.data.apiserver\\.crt}'")
      (changed_when "false")
      (register "calico_apiserver_cabundle")
      (when (list
          "inventory_hostname == groups['kube_control_plane'][0]"
          "calico_apiserver_enabled")))
    (task "Calico | set calico apiserver caBundle fact"
      (set_fact 
        (calico_apiserver_cabundle (jinja "{{ calico_apiserver_cabundle.stdout }}")))
      (when (list
          "inventory_hostname == groups['kube_control_plane'][0]"
          "calico_apiserver_enabled")))
    (task "Calico | Create calico manifests for apiserver"
      (template 
        (src (jinja "{{ item.file }}") ".j2")
        (dest (jinja "{{ kube_config_dir }}") "/" (jinja "{{ item.file }}"))
        (mode "0644"))
      (with_items (list
          
          (name "calico")
          (file "calico-apiserver.yml")
          (type "calico-apiserver")))
      (register "calico_apiserver_manifest")
      (when (list
          "('kube_control_plane' in group_names)"
          "calico_apiserver_enabled")))
    (task "Start Calico resources"
      (kube 
        (name (jinja "{{ item.item.name }}"))
        (namespace "kube-system")
        (kubectl (jinja "{{ bin_dir }}") "/kubectl")
        (resource (jinja "{{ item.item.type }}"))
        (filename (jinja "{{ kube_config_dir }}") "/" (jinja "{{ item.item.file }}"))
        (state "latest"))
      (with_items (list
          (jinja "{{ calico_node_manifests.results }}")
          (jinja "{{ calico_node_typha_manifest.results }}")))
      (when (list
          "inventory_hostname == groups['kube_control_plane'][0]"
          "not item is skipped"))
      (loop_control 
        (label (jinja "{{ item.item.file }}"))))
    (task "Start Calico apiserver resources"
      (kube 
        (name (jinja "{{ item.item.name }}"))
        (namespace "calico-apiserver")
        (kubectl (jinja "{{ bin_dir }}") "/kubectl")
        (resource (jinja "{{ item.item.type }}"))
        (filename (jinja "{{ kube_config_dir }}") "/" (jinja "{{ item.item.file }}"))
        (state "latest"))
      (with_items (list
          (jinja "{{ calico_apiserver_manifest.results }}")))
      (when (list
          "inventory_hostname == groups['kube_control_plane'][0]"
          "not item is skipped"))
      (loop_control 
        (label (jinja "{{ item.item.file }}"))))
    (task "Wait for calico kubeconfig to be created"
      (wait_for 
        (path "/etc/cni/net.d/calico-kubeconfig")
        (timeout (jinja "{{ calico_kubeconfig_wait_timeout }}")))
      (when (list
          "inventory_hostname not in groups['kube_control_plane']"
          "calico_datastore == \"kdd\"")))
    (task "Calico | Create Calico ipam manifests"
      (template 
        (src (jinja "{{ item.file }}") ".j2")
        (dest (jinja "{{ kube_config_dir }}") "/" (jinja "{{ item.file }}"))
        (mode "0644"))
      (with_items (list
          
          (name "calico")
          (file "calico-ipamconfig.yml")
          (type "ipam")))
      (when (list
          "('kube_control_plane' in group_names)"
          "calico_datastore == \"kdd\"")))
    (task "Calico | Create ipamconfig resources"
      (kube 
        (kubectl (jinja "{{ bin_dir }}") "/kubectl")
        (filename (jinja "{{ kube_config_dir }}") "/calico-ipamconfig.yml")
        (state "latest"))
      (register "resource_result")
      (until "resource_result is succeeded")
      (retries "4")
      (when (list
          "inventory_hostname == groups['kube_control_plane'][0]"
          "calico_datastore == \"kdd\"")))
    (task "Calico | Peer with Calico Route Reflector"
      (include_tasks "peer_with_calico_rr.yml")
      (when (list
          "peer_with_calico_rr | default(false)")))
    (task "Calico | Peer with the router"
      (include_tasks "peer_with_router.yml")
      (when (list
          "peer_with_router | default(false)")))))
