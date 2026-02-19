(playbook "kubespray/roles/reset/tasks/main.yml"
  (tasks
    (task "Reset | stop services"
      (service 
        (name (jinja "{{ item }}"))
        (state "stopped")
        (enabled "false"))
      (with_items (list
          "kubelet.service"
          "cri-dockerd.service"
          "cri-dockerd.socket"))
      (failed_when "false")
      (tags (list
          "services")))
    (task "Reset | remove services"
      (file 
        (path "/etc/systemd/system/" (jinja "{{ item }}"))
        (state "absent"))
      (with_items (list
          "kubelet.service"
          "cri-dockerd.service"
          "cri-dockerd.socket"
          "calico-node.service"
          "containerd.service.d/http-proxy.conf"
          "crio.service.d/http-proxy.conf"
          "k8s-certs-renew.service"
          "k8s-certs-renew.timer"))
      (register "services_removed")
      (tags (list
          "services"
          "containerd"
          "crio")))
    (task "Reset | Remove Docker"
      (include_role 
        (name "container-engine/docker")
        (tasks_from "reset"))
      (when "container_manager == 'docker'")
      (tags (list
          "docker")))
    (task "Reset | systemctl daemon-reload"
      (systemd_service 
        (daemon_reload "true"))
      (when "services_removed.changed"))
    (task "Reset | check if crictl is present"
      (stat 
        (path (jinja "{{ bin_dir }}") "/crictl")
        (get_attributes "false")
        (get_checksum "false")
        (get_mime "false"))
      (register "crictl"))
    (task "Reset | stop all cri containers"
      (shell "set -o pipefail && " (jinja "{{ bin_dir }}") "/crictl ps -q | xargs -r " (jinja "{{ bin_dir }}") "/crictl -t 60s stop -t " (jinja "{{ cri_stop_containers_grace_period }}"))
      (args 
        (executable "/bin/bash"))
      (register "remove_all_cri_containers")
      (retries "5")
      (until "remove_all_cri_containers.rc == 0")
      (delay "5")
      (tags (list
          "crio"
          "containerd"))
      (when (list
          "crictl.stat.exists"
          "container_manager in [\"crio\", \"containerd\"]"
          "ansible_facts.services['containerd.service'] is defined or ansible_facts.services['cri-o.service'] is defined"))
      (ignore_errors "true"))
    (task "Reset | force remove all cri containers"
      (command (jinja "{{ bin_dir }}") "/crictl rm -a -f")
      (register "remove_all_cri_containers")
      (retries "5")
      (until "remove_all_cri_containers.rc == 0")
      (delay "5")
      (tags (list
          "crio"
          "containerd"))
      (when (list
          "crictl.stat.exists"
          "container_manager in [\"crio\", \"containerd\"]"
          "deploy_container_engine"
          "ansible_facts.services['containerd.service'] is defined or ansible_facts.services['cri-o.service'] is defined"))
      (ignore_errors "true"))
    (task "Reset | stop and disable crio service"
      (service 
        (name "crio")
        (state "stopped")
        (enabled "false"))
      (failed_when "false")
      (tags (list
          "crio"))
      (when "container_manager == \"crio\""))
    (task "Reset | forcefully wipe CRI-O's container and image storage"
      (command "crio wipe -f")
      (failed_when "false")
      (tags (list
          "crio"))
      (when "container_manager == \"crio\""))
    (task "Reset | stop all cri pods"
      (shell "set -o pipefail && " (jinja "{{ bin_dir }}") "/crictl pods -q | xargs -r " (jinja "{{ bin_dir }}") "/crictl -t 60s stopp")
      (args 
        (executable "/bin/bash"))
      (register "remove_all_cri_containers")
      (retries "5")
      (until "remove_all_cri_containers.rc == 0")
      (delay "5")
      (tags (list
          "containerd"))
      (when (list
          "crictl.stat.exists"
          "container_manager == \"containerd\""
          "ansible_facts.services['containerd.service'] is defined or ansible_facts.services['cri-o.service'] is defined"))
      (ignore_errors "true"))
    (task "Reset | force remove all cri pods"
      (block (list
          
          (name "Reset | force remove all cri pods")
          (command (jinja "{{ bin_dir }}") "/crictl rmp -a -f")
          (register "remove_all_cri_containers")
          (retries "5")
          (until "remove_all_cri_containers.rc == 0")
          (delay "5")
          (tags (list
              "containerd"))
          (when (list
              "crictl.stat.exists"
              "container_manager == \"containerd\""
              "ansible_facts.services['containerd.service'] is defined or ansible_facts.services['cri-o.service'] is defined"))))
      (rescue (list
          
          (name "Reset | force remove all cri pods (rescue)")
          (shell "ip netns list | cut -d' ' -f 1 | xargs -n1 ip netns delete && " (jinja "{{ bin_dir }}") "/crictl rmp -a -f")
          (ignore_errors "true")
          (changed_when "true"))))
    (task "Reset | stop containerd and etcd services"
      (service 
        (name (jinja "{{ item }}"))
        (state "stopped")
        (enabled "false"))
      (with_items (list
          "containerd.service"
          "etcd.service"
          "etcd-events.service"))
      (failed_when "false")
      (tags (list
          "services")))
    (task "Reset | remove containerd and etcd services"
      (file 
        (path "/etc/systemd/system/" (jinja "{{ item }}"))
        (state "absent"))
      (with_items (list
          "containerd.service"
          "etcd.service"
          "etcd-events.service"))
      (register "services_removed_secondary")
      (tags (list
          "services"
          "containerd")))
    (task "Reset | systemctl daemon-reload"
      (systemd_service 
        (daemon_reload "true"))
      (when "services_removed_secondary.changed"))
    (task "Reset | gather mounted kubelet dirs"
      (shell "set -o pipefail && mount | grep /var/lib/kubelet/ | awk '{print $3}' | tac")
      (args 
        (executable "/bin/bash"))
      (check_mode "false")
      (register "mounted_dirs")
      (failed_when "false")
      (changed_when "false")
      (tags (list
          "mounts")))
    (task "Reset | unmount kubelet dirs"
      (command "umount -f " (jinja "{{ item }}"))
      (with_items (jinja "{{ mounted_dirs.stdout_lines }}"))
      (register "umount_dir")
      (when "mounted_dirs")
      (retries "4")
      (until "umount_dir.rc == 0")
      (delay "5")
      (tags (list
          "mounts")))
    (task "Set IPv4 iptables default policies to ACCEPT"
      (iptables 
        (chain (jinja "{{ item }}"))
        (policy "ACCEPT"))
      (with_items (list
          "INPUT"
          "FORWARD"
          "OUTPUT"))
      (when "flush_iptables | bool and ipv4_stack")
      (tags (list
          "iptables")))
    (task "Flush iptables"
      (iptables 
        (table (jinja "{{ item }}"))
        (flush "true"))
      (with_items (list
          "filter"
          "nat"
          "mangle"
          "raw"))
      (when "flush_iptables | bool and ipv4_stack")
      (tags (list
          "iptables")))
    (task "Delete IPv4 user-defined chains"
      (command "iptables -X")
      (when "flush_iptables | bool and ipv4_stack")
      (tags (list
          "iptables")))
    (task "Set IPv6 ip6tables default policies to ACCEPT"
      (iptables 
        (chain (jinja "{{ item }}"))
        (policy "ACCEPT")
        (ip_version "ipv6"))
      (with_items (list
          "INPUT"
          "FORWARD"
          "OUTPUT"))
      (when "flush_iptables | bool and ipv6_stack")
      (tags (list
          "ip6tables")))
    (task "Flush ip6tables"
      (iptables 
        (table (jinja "{{ item }}"))
        (flush "true")
        (ip_version "ipv6"))
      (with_items (list
          "filter"
          "nat"
          "mangle"
          "raw"))
      (when "flush_iptables | bool and ipv6_stack")
      (tags (list
          "ip6tables")))
    (task "Delete IPv6 user-defined chains"
      (command "ip6tables -X")
      (when "flush_iptables | bool and ipv6_stack")
      (tags (list
          "ip6tables")))
    (task "Clear IPVS virtual server table"
      (command "ipvsadm -C")
      (ignore_errors "true")
      (when (list
          "kube_proxy_mode == 'ipvs' and 'k8s_cluster' in group_names")))
    (task "Reset | check kube-ipvs0 network device"
      (stat 
        (path "/sys/class/net/kube-ipvs0")
        (get_attributes "false")
        (get_checksum "false")
        (get_mime "false"))
      (register "kube_ipvs0"))
    (task "Reset | Remove kube-ipvs0"
      (command "ip link del kube-ipvs0")
      (when (list
          "kube_proxy_mode == 'ipvs'"
          "kube_ipvs0.stat.exists")))
    (task "Reset | check nodelocaldns network device"
      (stat 
        (path "/sys/class/net/nodelocaldns")
        (get_attributes "false")
        (get_checksum "false")
        (get_mime "false"))
      (register "nodelocaldns_device"))
    (task "Reset | Remove nodelocaldns"
      (command "ip link del nodelocaldns")
      (when (list
          "enable_nodelocaldns | default(false) | bool"
          "nodelocaldns_device.stat.exists")))
    (task "Reset | Check whether /var/lib/kubelet directory exists"
      (stat 
        (path "/var/lib/kubelet")
        (get_attributes "false")
        (get_checksum "false")
        (get_mime "false"))
      (register "var_lib_kubelet_directory"))
    (task "Reset | Find files/dirs with immutable flag in /var/lib/kubelet"
      (command "lsattr -laR /var/lib/kubelet/")
      (become "true")
      (register "var_lib_kubelet_files_dirs_w_attrs")
      (changed_when "false")
      (no_log "true")
      (when "var_lib_kubelet_directory.stat.exists"))
    (task "Reset | Remove immutable flag from files/dirs in /var/lib/kubelet"
      (file 
        (path (jinja "{{ filedir_path }}"))
        (state "touch")
        (attributes "-i")
        (mode "0644"))
      (loop (jinja "{{ var_lib_kubelet_files_dirs_w_attrs.stdout_lines | select('search', 'Immutable') | list }}"))
      (loop_control 
        (loop_var "file_dir_line")
        (label (jinja "{{ filedir_path }}")))
      (vars 
        (filedir_path (jinja "{{ file_dir_line.split(' ')[0] }}")))
      (when "var_lib_kubelet_directory.stat.exists"))
    (task "Reset | delete some files and directories"
      (file 
        (path (jinja "{{ item }}"))
        (state "absent"))
      (with_items (list
          (jinja "{{ kube_config_dir }}")
          "/var/lib/kubelet"
          (jinja "{{ containerd_storage_dir }}")
          (jinja "{{ ansible_env.HOME | default('/root') }}") "/.kube"
          (jinja "{{ ansible_env.HOME | default('/root') }}") "/.helm"
          (jinja "{{ ansible_env.HOME | default('/root') }}") "/.config/helm"
          (jinja "{{ ansible_env.HOME | default('/root') }}") "/.cache/helm"
          (jinja "{{ ansible_env.HOME | default('/root') }}") "/.local/share/helm"
          (jinja "{{ etcd_data_dir }}")
          (jinja "{{ etcd_events_data_dir }}")
          (jinja "{{ etcd_config_dir }}")
          "/var/log/calico"
          "/var/log/openvswitch"
          "/var/log/ovn"
          "/var/log/kube-ovn"
          "/var/log/containers"
          "/etc/cni"
          "/etc/nerdctl"
          (jinja "{{ nginx_config_dir }}")
          "/etc/systemd/resolved.conf.d/kubespray.conf"
          "/etc/etcd.env"
          "/etc/calico"
          "/etc/NetworkManager/conf.d/calico.conf"
          "/etc/NetworkManager/conf.d/dns.conf"
          "/etc/NetworkManager/conf.d/k8s.conf"
          "/opt/cni"
          "/etc/dhcp/dhclient.d/zdnsupdate.sh"
          "/etc/dhcp/dhclient-exit-hooks.d/zdnsupdate"
          "/run/flannel"
          "/etc/flannel"
          "/run/kubernetes"
          "/usr/local/share/ca-certificates/etcd-ca.crt"
          "/usr/local/share/ca-certificates/kube-ca.crt"
          "/etc/ssl/certs/etcd-ca.pem"
          "/etc/ssl/certs/kube-ca.pem"
          "/etc/pki/ca-trust/source/anchors/etcd-ca.crt"
          "/etc/pki/ca-trust/source/anchors/kube-ca.crt"
          "/var/log/pods/"
          (jinja "{{ bin_dir }}") "/kubelet"
          (jinja "{{ bin_dir }}") "/cri-dockerd"
          (jinja "{{ bin_dir }}") "/etcd-scripts"
          (jinja "{{ bin_dir }}") "/etcd"
          (jinja "{{ bin_dir }}") "/etcd-events"
          (jinja "{{ bin_dir }}") "/etcdctl"
          (jinja "{{ bin_dir }}") "/etcdctl.sh"
          (jinja "{{ bin_dir }}") "/kubernetes-scripts"
          (jinja "{{ bin_dir }}") "/kubectl"
          (jinja "{{ bin_dir }}") "/kubeadm"
          (jinja "{{ bin_dir }}") "/helm"
          (jinja "{{ bin_dir }}") "/calicoctl"
          (jinja "{{ bin_dir }}") "/calicoctl.sh"
          (jinja "{{ bin_dir }}") "/calico-upgrade"
          (jinja "{{ bin_dir }}") "/crictl"
          (jinja "{{ bin_dir }}") "/nerdctl"
          (jinja "{{ bin_dir }}") "/netctl"
          (jinja "{{ bin_dir }}") "/k8s-certs-renew.sh"
          "/var/lib/cni"
          "/etc/openvswitch"
          "/run/openvswitch"
          "/var/lib/kube-router"
          "/var/lib/calico"
          "/etc/cilium"
          "/run/calico"
          "/etc/bash_completion.d/kubectl.sh"
          "/etc/bash_completion.d/crictl"
          "/etc/bash_completion.d/nerdctl"
          "/etc/modules-load.d/kube_proxy-ipvs.conf"
          "/etc/modules-load.d/kubespray-br_netfilter.conf"
          "/etc/modules-load.d/kubespray-kata-containers.conf"
          "/usr/libexec/kubernetes"
          "/etc/origin/openvswitch"
          "/etc/origin/ovn"
          (jinja "{{ sysctl_file_path }}")
          "/etc/crictl.yaml"))
      (ignore_errors "true")
      (tags (list
          "files")))
    (task "Reset | remove containerd binary files"
      (file 
        (path (jinja "{{ containerd_bin_dir }}") "/" (jinja "{{ item }}"))
        (state "absent"))
      (with_items (list
          "containerd"
          "containerd-shim"
          "containerd-shim-runc-v1"
          "containerd-shim-runc-v2"
          "containerd-stress"
          "crictl"
          "critest"
          "ctd-decoder"
          "ctr"
          "runc"))
      (ignore_errors "true")
      (when "container_manager == 'containerd'")
      (tags (list
          "files")))
    (task "Reset | remove dns settings from dhclient.conf"
      (blockinfile 
        (path (jinja "{{ item }}"))
        (state "absent")
        (marker "# Ansible entries {mark}"))
      (failed_when "false")
      (with_items (list
          "/etc/dhclient.conf"
          "/etc/dhcp/dhclient.conf"))
      (tags (list
          "files"
          "dns")))
    (task "Reset | include file with reset tasks specific to the network_plugin if exists"
      (include_role 
        (name "network_plugin/" (jinja "{{ kube_network_plugin }}"))
        (tasks_from "reset"))
      (when (list
          "kube_network_plugin in ['flannel', 'cilium', 'kube-router', 'calico']"))
      (tags (list
          "network")))
    (task "Reset | Restart network"
      (block (list
          
          (name "Gather active network services")
          (systemd 
            (name (jinja "{{ item }}")))
          (loop (list
              "NetworkManager"
              "systemd-networkd"
              "networking"
              "network"))
          (register "service_status")
          (changed_when "false")
          (ignore_errors "true")
          
          (name "Restart active network services")
          (systemd 
            (name (jinja "{{ item }}"))
            (state "restarted"))
          (loop (jinja "{{ service_status.results | selectattr('status.ActiveState', '==', 'active') | map(attribute='item') }}"))))
      (when (list
          "ansible_os_family not in [\"Flatcar\", \"Flatcar Container Linux by Kinvolk\"]"
          "reset_restart_network | bool"))
      (tags (list
          "services"
          "network")))))
