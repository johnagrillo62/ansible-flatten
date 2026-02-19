(playbook "debops/ansible/roles/ifupdown/defaults/main.yml"
  (ifupdown__base_packages (list
      (list
        "ifupdown"
        "bsdutils"
        "rsync")
      (jinja "{{ []
        if (\"/usr/sbin/NetworkManager\" in ansible_local.ifupdown.known_managers | d([]))
        else \"rdnssd\" }}")))
  (ifupdown__dynamic_packages (jinja "{{ lookup(\"template\", \"lookup/ifupdown__dynamic_packages.j2\", convert_data=False) | from_yaml }}"))
  (ifupdown__packages (list))
  (ifupdown__purge_packages (list
      "netplan.io"
      "nplan"))
  (ifupdown__interface_weight_map 
    (mapping "00")
    (bonding "10")
    (ether "20")
    (slip "30")
    (wlan "30")
    (wwan "30")
    (vlan "40")
    (bridge "60")
    (6to4 "80")
    (tunnel "80")
    (default "80"))
  (ifupdown__reconfigure_auto "True")
  (ifupdown__reconfigure_script_path (jinja "{{ (ansible_local.fhs.lib | d(\"/usr/local/lib\"))
                                       + \"/ifupdown-reconfigure-interfaces\" }}"))
  (ifupdown__reconfigure_init_file "/etc/network/interfaces.d/old-interfaces")
  (ifupdown__default_nat_masquerade "False")
  (ifupdown__external_interface (jinja "{{ ansible_local.ifupdown.external_interface | d(lookup(\"template\", \"lookup/ifupdown__external_interface.j2\", convert_data=False) | from_yaml) }}"))
  (ifupdown__internal_interface (jinja "{{ ansible_local.ifupdown.internal_interface | d(lookup(\"template\", \"lookup/ifupdown__internal_interface.j2\", convert_data=False) | from_yaml) }}"))
  (ifupdown__interface_layout (jinja "{{ \"dynamic\"
                                if (ansible_virtualization_type in [\"lxc\", \"openvz\"] and
                                    ansible_virtualization_role == \"guest\")
                                else \"bridge\" }}"))
  (ifupdown__default_interfaces_map 
    (static 
      (external 
        (iface (jinja "{{ ansible_default_ipv4.interface | d(\"\") }}"))
        (inet "static")
        (inet6 "auto")
        (address (jinja "{{ (ansible_default_ipv4.address | d(\"\") + \"/\" +
                    ansible_default_ipv4.netmask | d(\"\")) }}"))
        (gateway (jinja "{{ ansible_default_ipv4.gateway | d(\"\") }}"))
        (dns_nameservers (jinja "{{ ansible_dns.nameservers | d(False) }}"))
        (dns_search (jinja "{{ ansible_dns.search | d(False) }}"))))
    (dynamic 
      (external 
        (iface (jinja "{{ ifupdown__external_interface }}"))
        (inet "dhcp")
        (inet6 "auto")
        (state (jinja "{{ \"present\"
                 if ifupdown__external_interface in ansible_interfaces
                 else \"ignore\" }}")))
      (internal 
        (iface (jinja "{{ ifupdown__internal_interface }}"))
        (inet "dhcp")
        (inet6 "auto")
        (state (jinja "{{ \"present\"
                 if ifupdown__internal_interface in ansible_interfaces
                 else \"ignore\" }}")))
      (br0 
        (state (jinja "{{ \"absent\"
                 if (ansible_local.ifupdown.interface_layout | d() == \"bridge\")
                 else \"ignore\" }}")))
      (br1 
        (state (jinja "{{ \"absent\"
                 if (ansible_local.ifupdown.interface_layout | d() == \"bridge\")
                 else \"ignore\" }}"))))
    (bridge 
      (external 
        (iface (jinja "{{ ifupdown__external_interface }}"))
        (inet "manual")
        (inet6 "False")
        (state (jinja "{{ \"present\"
                 if ifupdown__external_interface in ansible_interfaces
                 else \"ignore\" }}")))
      (internal 
        (iface (jinja "{{ ifupdown__internal_interface }}"))
        (inet "manual")
        (inet6 "False")
        (state (jinja "{{ \"present\"
                 if ifupdown__internal_interface in ansible_interfaces
                 else \"ignore\" }}")))
      (br0 
        (inet "dhcp")
        (inet6 "auto")
        (type "bridge")
        (forward "True")
        (bridge_ports (jinja "{{ ifupdown__external_interface }}"))
        (state (jinja "{{ \"present\"
                 if ifupdown__external_interface in ansible_interfaces
                 else \"ignore\" }}")))
      (br1 
        (inet "dhcp")
        (inet6 "auto")
        (type "bridge")
        (forward "True")
        (bridge_ports (jinja "{{ ifupdown__internal_interface }}"))
        (state (jinja "{{ \"present\"
                 if ifupdown__internal_interface in ansible_interfaces
                 else \"ignore\" }}"))))
    (manual ))
  (ifupdown__ethernet_interfaces (jinja "{{ lookup(\"template\", \"lookup/ifupdown__ethernet_interfaces.j2\", convert_data=False) | from_yaml }}"))
  (ifupdown__default_interfaces (jinja "{{ ifupdown__default_interfaces_map[ifupdown__interface_layout] | d({}) }}"))
  (ifupdown__interfaces )
  (ifupdown__group_interfaces )
  (ifupdown__host_interfaces )
  (ifupdown__dependent_interfaces )
  (ifupdown__combined_interfaces (jinja "{{ lookup(\"template\", \"lookup/ifupdown__combined_interfaces.j2\", convert_data=False) | from_yaml }}"))
  (ifupdown__custom_hooks (list
      
      (name "filter-dhcp-options")
      (hook "etc/dhcp/dhclient-enter-hooks.d/filter-dhcp-options")
      (mode "0644")
      (state "present")))
  (ifupdown__custom_files (list))
  (ifupdown__custom_group_files (list))
  (ifupdown__custom_host_files (list))
  (ifupdown__custom_dependent_files (list))
  (ifupdown__ferm__dependent_rules (jinja "{{ lookup(\"template\", \"lookup/ifupdown__ferm__dependent_rules.j2\", convert_data=False) | from_yaml }}"))
  (ifupdown__kmod__dependent_load (jinja "{{ lookup(\"template\", \"lookup/ifupdown__kmod__dependent_load.j2\", convert_data=False) | from_yaml }}"))
  (ifupdown__sysctl__dependent_parameters (jinja "{{ lookup(\"template\",
                                            \"lookup/ifupdown__sysctl__dependent_parameters.j2\",
                                            convert_data=False) | from_yaml }}"))
  (ifupdown__role_metadata 
    (version "0.3.0")))
