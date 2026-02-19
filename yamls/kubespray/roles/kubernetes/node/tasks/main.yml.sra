(playbook "kubespray/roles/kubernetes/node/tasks/main.yml"
  (tasks
    (task "Fetch facts"
      (import_tasks "facts.yml")
      (tags (list
          "facts"
          "kubelet")))
    (task "Ensure /var/lib/cni exists"
      (file 
        (path "/var/lib/cni")
        (state "directory")
        (mode "0755")))
    (task "Install kubelet binary"
      (import_tasks "install.yml")
      (tags (list
          "kubelet")))
    (task "Install kube-vip"
      (import_tasks "loadbalancer/kube-vip.yml")
      (when (list
          "('kube_control_plane' in group_names)"
          "kube_vip_enabled"))
      (tags (list
          "kube-vip")))
    (task "Install nginx-proxy"
      (import_tasks "loadbalancer/nginx-proxy.yml")
      (when (list
          "('kube_control_plane' not in group_names) or (kube_apiserver_bind_address != '::')"
          "loadbalancer_apiserver_localhost"
          "loadbalancer_apiserver_type == 'nginx'"))
      (tags (list
          "nginx")))
    (task "Install haproxy"
      (import_tasks "loadbalancer/haproxy.yml")
      (when (list
          "('kube_control_plane' not in group_names) or (kube_apiserver_bind_address != '::')"
          "loadbalancer_apiserver_localhost"
          "loadbalancer_apiserver_type == 'haproxy'"))
      (tags (list
          "haproxy")))
    (task "Ensure nodePort range is reserved"
      (ansible.posix.sysctl 
        (name "net.ipv4.ip_local_reserved_ports")
        (value (jinja "{{ kube_apiserver_node_port_range }}"))
        (sysctl_set "true")
        (sysctl_file (jinja "{{ sysctl_file_path }}"))
        (state "present")
        (reload "true")
        (ignoreerrors (jinja "{{ sysctl_ignore_unknown_keys }}")))
      (when "kube_apiserver_node_port_range is defined")
      (tags (list
          "kube-proxy")))
    (task "Verify if br_netfilter module exists"
      (command "modinfo br_netfilter")
      (environment 
        (PATH (jinja "{{ ansible_env.PATH }}") ":/sbin"))
      (register "modinfo_br_netfilter")
      (failed_when "modinfo_br_netfilter.rc not in [0, 1]")
      (changed_when "false")
      (check_mode "false"))
    (task "Verify br_netfilter module path exists"
      (file 
        (path (jinja "{{ item }}"))
        (state "directory")
        (mode "0755"))
      (loop (list
          "/etc/modules-load.d"
          "/etc/modprobe.d")))
    (task "Enable br_netfilter module"
      (community.general.modprobe 
        (name "br_netfilter")
        (state "present"))
      (when "modinfo_br_netfilter.rc == 0"))
    (task "Persist br_netfilter module"
      (copy 
        (dest "/etc/modules-load.d/kubespray-br_netfilter.conf")
        (content "br_netfilter")
        (mode "0644"))
      (when "modinfo_br_netfilter.rc == 0"))
    (task "Check if bridge-nf-call-iptables key exists"
      (command "sysctl net.bridge.bridge-nf-call-iptables")
      (failed_when "false")
      (changed_when "false")
      (check_mode "false")
      (register "sysctl_bridge_nf_call_iptables"))
    (task "Enable bridge-nf-call tables"
      (ansible.posix.sysctl 
        (name (jinja "{{ item }}"))
        (state "present")
        (sysctl_file (jinja "{{ sysctl_file_path }}"))
        (value "1")
        (reload "true")
        (ignoreerrors (jinja "{{ sysctl_ignore_unknown_keys }}")))
      (when "sysctl_bridge_nf_call_iptables.rc == 0")
      (with_items (list
          "net.bridge.bridge-nf-call-iptables"
          "net.bridge.bridge-nf-call-arptables"
          "net.bridge.bridge-nf-call-ip6tables")))
    (task "Modprobe Kernel Module for IPVS"
      (community.general.modprobe 
        (name (jinja "{{ item }}"))
        (state "present")
        (persistent "present"))
      (loop (jinja "{{ kube_proxy_ipvs_modules }}"))
      (when "kube_proxy_mode == 'ipvs'")
      (tags (list
          "kube-proxy")))
    (task "Modprobe conntrack module"
      (community.general.modprobe 
        (name (jinja "{{ item }}"))
        (state "present")
        (persistent "present"))
      (register "modprobe_conntrack_module")
      (ignore_errors "true")
      (loop (list
          "nf_conntrack"
          "nf_conntrack_ipv4"))
      (when (list
          "kube_proxy_mode == 'ipvs'"
          "modprobe_conntrack_module is not defined or modprobe_conntrack_module is ansible.builtin.failed"))
      (tags (list
          "kube-proxy")))
    (task "Modprobe Kernel Module for nftables"
      (community.general.modprobe 
        (name "nf_tables")
        (state "present")
        (persistent "present"))
      (when "kube_proxy_mode == 'nftables'")
      (tags (list
          "kube-proxy")))
    (task "Install kubelet"
      (import_tasks "kubelet.yml")
      (tags (list
          "kubelet"
          "kubeadm")))))
