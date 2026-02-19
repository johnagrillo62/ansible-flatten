(playbook "debops/ansible/roles/dhcpd/defaults/main.yml"
  (dhcpd__base_packages (list
      "isc-dhcp-server"))
  (dhcpd__packages (list))
  (dhcpd__options "")
  (dhcpd__interfacesv4 (list
      (jinja "{{ ansible_local.ifupdown.external_interface
                           if ansible_local.ifupdown.external_interface | d()
                           else ansible_default_ipv4.interface }}")))
  (dhcpd__interfacesv6 (jinja "{{ dhcpd__interfacesv4
                         if ansible_default_ipv6.address | d()
                         else [] }}"))
  (dhcpd__authoritative "False")
  (dhcpd__log_facility "daemon")
  (dhcpd__default_lease_time (jinja "{{ 60 * 60 * 12 }}"))
  (dhcpd__max_lease_time (jinja "{{ 60 * 60 * 24 }}"))
  (dhcpd__preferred_lifetime (jinja "{{ (dhcpd__default_lease_time | float * (5 / 8)) | int }}"))
  (dhcpd__dhcpv6_set_tee_times "True")
  (dhcpd__update_static_leases "False")
  (dhcpd__domain_name (jinja "{{ ansible_domain }}"))
  (dhcpd__domain_search (jinja "{{ ansible_dns.search | d([]) }}"))
  (dhcpd__name_servers (jinja "{{ ansible_local.resolvconf.upstream_nameservers
                         if (ansible_local.resolvconf.upstream_nameservers | d())
                         else (ansible_dns.nameservers
                               if (\"127.0.0.1\" not in ansible_dns.nameservers)
                               else []) }}"))
  (dhcpd__global_options_map 
    (DHCPv4 "")
    (DHCPv6 ""))
  (dhcpd__ipxe "False")
  (dhcpd__ipxe_dhcp_space "True")
  (dhcpd__ipxe_tftp_server (jinja "{{ ansible_default_ipv4.address }}"))
  (dhcpd__ipxe_chain_filename "undionly.kpxe")
  (dhcpd__ipxe_efi_chain_filename "ipxe.efi")
  (dhcpd__ipxe_filename "menu.ipxe")
  (dhcpd__ipxe_options "")
  (dhcpd__classes (list))
  (dhcpd__failovers (list))
  (dhcpd__groups (list))
  (dhcpd__hosts (list))
  (dhcpd__keys (list))
  (dhcpd__shared_networks (list))
  (dhcpd__subnets (jinja "{{ dhcpd__default_subnets }}"))
  (dhcpd__default_subnets (list
      
      (comment "Autodetected IPv4 subnet")
      (subnet (jinja "{{ ansible_default_ipv4.network
                + \"/\" + ansible_default_ipv4.netmask }}"))
      (routers (jinja "{{ [ansible_default_ipv4.gateway]
                 if ansible_default_ipv4.gateway | d()
                 else [] }}"))
      
      (comment "Autodetected IPv6 subnet")
      (subnet (jinja "{{ ansible_default_ipv6.address | d()
                + \"/\" + ansible_default_ipv6.prefix | d() }}"))
      (state (jinja "{{ \"present\" if ansible_default_ipv6.address | d() else \"absent\" }}"))))
  (dhcpd__zones (list))
  (dhcpd__etc_services__dependent_list (list
      
      (name "dhcp-failover")
      (port "647")
      (protocols (list
          "tcp"
          "udp"))
      (comment "Added by debops.dhcpd Ansible role")))
  (dhcpd__ferm__dependent_rules (list
      
      (name "accept_dhcpv6_server")
      (by_role "debops.dhcpd")
      (type "accept")
      (interface (jinja "{{ dhcpd__interfacesv6 }}"))
      (protocol "udp")
      (dport (list
          "dhcpv6-server"))
      (rule_state (jinja "{{ \"present\" if dhcpd__interfacesv6 else \"absent\" }}"))
      
      (name "accept_dhcp_failover")
      (by_role "debops.dhcpd")
      (type "accept")
      (saddr (jinja "{{ (dhcpd__failovers | map(attribute=\"primary\") | list
                + dhcpd__failovers | map(attribute=\"secondary\") | list)
               if dhcpd__failovers
               else omit }}"))
      (protocol "tcp")
      (dport (list
          "dhcp-failover"))
      (rule_state (jinja "{{ \"present\" if dhcpd__failovers else \"absent\" }}")))))
