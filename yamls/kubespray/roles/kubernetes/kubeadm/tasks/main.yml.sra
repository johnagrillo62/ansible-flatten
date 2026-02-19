(playbook "kubespray/roles/kubernetes/kubeadm/tasks/main.yml"
  (tasks
    (task "Set kubeadm_discovery_address"
      (set_fact 
        (kubeadm_discovery_address (jinja "{%- if \"127.0.0.1\" in kube_apiserver_endpoint or \"localhost\" in kube_apiserver_endpoint -%}") " " (jinja "{{ first_kube_control_plane_address | ansible.utils.ipwrap }}") ":" (jinja "{{ kube_apiserver_port }}") " " (jinja "{%- else -%}") " " (jinja "{{ kube_apiserver_endpoint | replace(\"https://\", \"\") }}") " " (jinja "{%- endif %}")))
      (tags (list
          "facts")))
    (task "Check if kubelet.conf exists"
      (stat 
        (path (jinja "{{ kube_config_dir }}") "/kubelet.conf")
        (get_attributes "false")
        (get_checksum "false")
        (get_mime "false"))
      (register "kubelet_conf"))
    (task "Check if kubeadm CA cert is accessible"
      (stat 
        (path (jinja "{{ kube_cert_dir }}") "/ca.crt")
        (get_attributes "false")
        (get_checksum "false")
        (get_mime "false"))
      (register "kubeadm_ca_stat")
      (delegate_to (jinja "{{ groups['kube_control_plane'][0] }}"))
      (run_once "true"))
    (task "Fetch CA certificate from control plane node"
      (slurp 
        (src (jinja "{{ kube_cert_dir }}") "/ca.crt"))
      (register "ca_cert_content")
      (when (list
          "kubeadm_ca_stat.stat is defined"
          "kubeadm_ca_stat.stat.exists"))
      (delegate_to (jinja "{{ groups['kube_control_plane'][0] }}"))
      (run_once "true"))
    (task "Create kubeadm token for joining nodes with 24h expiration (default)"
      (command (jinja "{{ bin_dir }}") "/kubeadm token create")
      (register "temp_token")
      (delegate_to (jinja "{{ groups['kube_control_plane'][0] }}"))
      (when "kubeadm_token is not defined")
      (changed_when "false"))
    (task "Set kubeadm_token to generated token"
      (set_fact 
        (kubeadm_token (jinja "{{ temp_token.stdout }}")))
      (when "kubeadm_token is not defined"))
    (task "Get kubeconfig for join discovery process"
      (command (jinja "{{ kubectl }}") " -n kube-public get cm cluster-info -o jsonpath='{.data.kubeconfig}'")
      (register "kubeconfig_file_discovery")
      (run_once "true")
      (delegate_to (jinja "{{ groups['kube_control_plane'] | first }}"))
      (when "kubeadm_use_file_discovery"))
    (task "Check if discovery kubeconfig exists"
      (stat 
        (path (jinja "{{ kube_config_dir }}") "/cluster-info-discovery-kubeconfig.yaml"))
      (register "cluster_info_discovery_kubeconfig"))
    (task "Copy discovery kubeconfig"
      (copy 
        (dest (jinja "{{ kube_config_dir }}") "/cluster-info-discovery-kubeconfig.yaml")
        (content (jinja "{{ kubeconfig_file_discovery.stdout }}"))
        (owner "root")
        (mode "0644"))
      (when (list
          "('kube_control_plane' not in group_names)"
          "not kubelet_conf.stat.exists or not cluster_info_discovery_kubeconfig.stat.exists"
          "kubeadm_use_file_discovery")))
    (task "Create kubeadm client config"
      (template 
        (src "kubeadm-client.conf.j2")
        (dest (jinja "{{ kube_config_dir }}") "/kubeadm-client.conf")
        (backup "true")
        (mode "0640")
        (validate (jinja "{{ kubeadm_config_validate_enabled | ternary(bin_dir + '/kubeadm config validate --config %s', omit) }}")))
      (when "('kube_control_plane' not in group_names)"))
    (task "Join to cluster if needed"
      (command "timeout -k " (jinja "{{ kubeadm_join_timeout }}") " " (jinja "{{ kubeadm_join_timeout }}") " " (jinja "{{ bin_dir }}") "/kubeadm join --config " (jinja "{{ kube_config_dir }}") "/kubeadm-client.conf --ignore-preflight-errors=" (jinja "{{ ignored | select | flatten | join(',') }}") " --skip-phases=" (jinja "{{ kubeadm_join_phases_skip | join(',') }}"))
      (environment 
        (PATH (jinja "{{ bin_dir }}") ":" (jinja "{{ ansible_env.PATH }}") ":/sbin"))
      (when (list
          "('kube_control_plane' not in group_names)"
          "not kubelet_conf.stat.exists"))
      (vars 
        (ignored (list
            (jinja "{{ 'DirAvailable--etc-kubernetes-manifests' if 'all' not in kubeadm_ignore_preflight_errors }}")
            (jinja "{{ kubeadm_ignore_preflight_errors }}")))))
    (task "Update server field in kubelet kubeconfig"
      (lineinfile 
        (dest (jinja "{{ kube_config_dir }}") "/kubelet.conf")
        (regexp "server:")
        (line "    server: " (jinja "{{ kube_apiserver_endpoint }}"))
        (backup "true"))
      (when (list
          "kubeadm_config_api_fqdn is not defined"
          "('kube_control_plane' not in group_names)"
          "kubeadm_discovery_address != kube_apiserver_endpoint | replace(\"https://\", \"\")"))
      (notify "Kubeadm | restart kubelet"))
    (task "Update server field in kubelet kubeconfig - external lb"
      (lineinfile 
        (dest (jinja "{{ kube_config_dir }}") "/kubelet.conf")
        (regexp "^    server: https")
        (line "    server: " (jinja "{{ kube_apiserver_endpoint }}"))
        (backup "true"))
      (when (list
          "('kube_control_plane' not in group_names)"
          "loadbalancer_apiserver is defined"))
      (notify "Kubeadm | restart kubelet"))
    (task "Get current resourceVersion of kube-proxy configmap"
      (command (jinja "{{ kubectl }}") " get configmap kube-proxy -n kube-system -o jsonpath='{.metadata.resourceVersion}'")
      (delegate_facts "false")
      (register "original_configmap_resource_version")
      (run_once "true")
      (delegate_to (jinja "{{ groups['kube_control_plane'] | first }}"))
      (when (list
          "kube_proxy_deployed"))
      (tags (list
          "kube-proxy")))
    (task "Update server field in kube-proxy kubeconfig"
      (shell "set -o pipefail && " (jinja "{{ kubectl }}") " get configmap kube-proxy -n kube-system -o yaml | sed 's#server:.*#server: https://127.0.0.1:" (jinja "{{ kube_apiserver_port }}") "#g' | " (jinja "{{ kubectl }}") " replace -f -")
      (delegate_facts "false")
      (args 
        (executable "/bin/bash"))
      (run_once "true")
      (delegate_to (jinja "{{ groups['kube_control_plane'] | first }}"))
      (when (list
          "kubeadm_config_api_fqdn is not defined"
          "kubeadm_discovery_address != kube_apiserver_endpoint | replace(\"https://\", \"\")"
          "kube_proxy_deployed"
          "loadbalancer_apiserver_localhost"))
      (tags (list
          "kube-proxy")))
    (task "Update server field in kube-proxy kubeconfig - external lb"
      (shell "set -o pipefail && " (jinja "{{ kubectl }}") " get configmap kube-proxy -n kube-system -o yaml | sed 's#server:.*#server: " (jinja "{{kube_apiserver_endpoint}}") "#g' | " (jinja "{{ kubectl }}") " replace -f -")
      (delegate_facts "false")
      (args 
        (executable "/bin/bash"))
      (run_once "true")
      (delegate_to (jinja "{{ groups['kube_control_plane'] | first }}"))
      (when (list
          "kube_proxy_deployed"
          "loadbalancer_apiserver is defined"))
      (tags (list
          "kube-proxy")))
    (task "Get new resourceVersion of kube-proxy configmap"
      (command (jinja "{{ kubectl }}") " get configmap kube-proxy -n kube-system -o jsonpath='{.metadata.resourceVersion}'")
      (delegate_facts "false")
      (register "new_configmap_resource_version")
      (run_once "true")
      (delegate_to (jinja "{{ groups['kube_control_plane'] | first }}"))
      (when (list
          "kube_proxy_deployed"))
      (tags (list
          "kube-proxy")))
    (task "Set ca.crt file permission"
      (file 
        (path (jinja "{{ kube_cert_dir }}") "/ca.crt")
        (owner "root")
        (group "root")
        (mode "0644")))
    (task "Restart all kube-proxy pods to ensure that they load the new configmap"
      (command (jinja "{{ kubectl }}") " delete pod -n kube-system -l k8s-app=kube-proxy --force --grace-period=0")
      (delegate_facts "false")
      (run_once "true")
      (delegate_to (jinja "{{ groups['kube_control_plane'] | first }}"))
      (when (list
          "kubeadm_config_api_fqdn is not defined or loadbalancer_apiserver is defined"
          "kubeadm_discovery_address != kube_apiserver_endpoint | replace(\"https://\", \"\") or loadbalancer_apiserver is defined"
          "kube_proxy_deployed"
          "original_configmap_resource_version.stdout != new_configmap_resource_version.stdout"))
      (tags (list
          "kube-proxy")))
    (task "Extract etcd certs from control plane if using etcd kubeadm mode"
      (include_tasks "kubeadm_etcd_node.yml")
      (when (list
          "etcd_deployment_type == \"kubeadm\""
          "inventory_hostname not in groups['kube_control_plane']"
          "kube_network_plugin in [\"calico\", \"flannel\", \"cilium\"] or cilium_deploy_additionally"
          "kube_network_plugin != \"calico\" or calico_datastore == \"etcd\""
          "kube_network_plugin != \"cilium\" or cilium_identity_allocation_mode != 'crd'")))))
