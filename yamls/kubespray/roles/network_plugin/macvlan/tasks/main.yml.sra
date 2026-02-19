(playbook "kubespray/roles/network_plugin/macvlan/tasks/main.yml"
  (tasks
    (task "Macvlan | Retrieve Pod Cidr"
      (command (jinja "{{ kubectl }}") " get nodes " (jinja "{{ kube_override_hostname | default(inventory_hostname) }}") " -o jsonpath='{.spec.podCIDR}'")
      (changed_when "false")
      (register "node_pod_cidr_cmd")
      (delegate_to (jinja "{{ groups['kube_control_plane'][0] }}")))
    (task "Macvlan | set node_pod_cidr"
      (set_fact 
        (node_pod_cidr (jinja "{{ node_pod_cidr_cmd.stdout }}"))))
    (task "Macvlan | Retrieve default gateway network interface"
      (raw "ip -4 route list 0/0 | sed 's/.*dev \\([[:alnum:]]*\\).*/\\1/'")
      (become "false")
      (changed_when "false")
      (register "node_default_gateway_interface_cmd"))
    (task "Macvlan | set node_default_gateway_interface"
      (set_fact 
        (node_default_gateway_interface (jinja "{{ node_default_gateway_interface_cmd.stdout | trim }}"))))
    (task "Macvlan | Install network gateway interface on debian"
      (template 
        (src "debian-network-macvlan.cfg.j2")
        (dest "/etc/network/interfaces.d/60-mac0.cfg")
        (mode "0644"))
      (notify "Macvlan | restart network")
      (when "ansible_os_family in [\"Debian\"]"))
    (task "Install macvlan config on RH distros"
      (block (list
          
          (name "Macvlan | Install macvlan script on centos")
          (copy 
            (src (jinja "{{ item }}"))
            (dest "/etc/sysconfig/network-scripts/")
            (owner "root")
            (group "root")
            (mode "0755"))
          (with_fileglob (list
              "files/*"))
          
          (name "Macvlan | Install post-up script on centos")
          (copy 
            (src "files/ifup-local")
            (dest "/sbin/")
            (owner "root")
            (group "root")
            (mode "0755"))
          (when "enable_nat_default_gateway")
          
          (name "Macvlan | Install network gateway interface on centos")
          (template 
            (src (jinja "{{ item.src }}") ".j2")
            (dest "/etc/sysconfig/network-scripts/" (jinja "{{ item.dst }}"))
            (mode "0644"))
          (with_items (list
              
              (src "centos-network-macvlan.cfg")
              (dst "ifcfg-mac0")
              
              (src "centos-routes-macvlan.cfg")
              (dst "route-mac0")
              
              (src "centos-postup-macvlan.cfg")
              (dst "post-up-mac0")))
          (notify "Macvlan | restart network")))
      (when "ansible_os_family == \"RedHat\""))
    (task "Install macvlan config on Flatcar"
      (block (list
          
          (name "Macvlan | Install service nat via gateway on Flatcar Container Linux")
          (template 
            (src "coreos-service-nat_ouside.j2")
            (dest "/etc/systemd/system/enable_nat_ouside.service")
            (mode "0644"))
          (when "enable_nat_default_gateway")
          
          (name "Macvlan | Enable service nat via gateway on Flatcar Container Linux")
          (command (jinja "{{ item }}"))
          (with_items (list
              "systemctl daemon-reload"
              "systemctl enable enable_nat_ouside.service"))
          (when "enable_nat_default_gateway")
          
          (name "Macvlan | Install network gateway interface on Flatcar Container Linux")
          (template 
            (src (jinja "{{ item.src }}") ".j2")
            (dest "/etc/systemd/network/" (jinja "{{ item.dst }}"))
            (mode "0644"))
          (with_items (list
              
              (src "coreos-device-macvlan.cfg")
              (dst "macvlan.netdev")
              
              (src "coreos-interface-macvlan.cfg")
              (dst "output.network")
              
              (src "coreos-network-macvlan.cfg")
              (dst "macvlan.network")))
          (notify "Macvlan | restart network")))
      (when "ansible_os_family in [\"Flatcar\", \"Flatcar Container Linux by Kinvolk\"]"))
    (task "Macvlan | Install cni definition for Macvlan"
      (template 
        (src "10-macvlan.conf.j2")
        (dest "/etc/cni/net.d/10-macvlan.conf")
        (mode "0644")))
    (task "Macvlan | Install loopback definition for Macvlan"
      (template 
        (src "99-loopback.conf.j2")
        (dest "/etc/cni/net.d/99-loopback.conf")
        (mode "0644")))
    (task "Enable net.ipv4.conf.all.arp_notify in sysctl"
      (ansible.posix.sysctl 
        (name "net.ipv4.conf.all.arp_notify")
        (value "1")
        (sysctl_set "true")
        (sysctl_file (jinja "{{ sysctl_file_path }}"))
        (state "present")
        (reload "true")
        (ignoreerrors (jinja "{{ sysctl_ignore_unknown_keys }}"))))))
