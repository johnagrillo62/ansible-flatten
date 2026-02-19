(playbook "debops/ansible/roles/resolvconf/defaults/main.yml"
  (resolvconf__enabled (jinja "{{ ansible_local.resolvconf.installed
                          | d(ansible_interfaces | count > 2 or
                            resolvconf__combined_services | d()) | bool }}"))
  (resolvconf__deploy_state "present")
  (resolvconf__base_packages (list
      "resolvconf"))
  (resolvconf__packages (list))
  (resolvconf__static_enabled "False")
  (resolvconf__static_filename "lo.static")
  (resolvconf__static_content "")
  (resolvconf__original_interface_order (list
      
      (name "loopback-interface")
      (value "lo.inet6
lo.inet
lo.@(dnsmasq|pdnsd)
lo.!(pdns|pdns-recursor)
lo
")
      
      (name "vpn-interfaces")
      (value "tun*
tap*
")
      
      (name "wwan-interfaces")
      (value "hso*")
      
      (name "ethernet-interfaces")
      (value "em+([0-9])?(_+([0-9]))*
p+([0-9])p+([0-9])?(_+([0-9]))*
@(br|eth)*([^.]).inet6
@(br|eth)*([^.]).ip6.@(dhclient|dhcpcd|pump|udhcpc)
@(br|eth)*([^.]).inet
@(br|eth)*([^.]).@(dhclient|dhcpcd|pump|udhcpc)
@(br|eth)*
")
      
      (name "wireless-interfaces")
      (value "@(ath|wifi|wlan)*([^.]).inet6
@(ath|wifi|wlan)*([^.]).ip6.@(dhclient|dhcpcd|pump|udhcpc)
@(ath|wifi|wlan)*([^.]).inet
@(ath|wifi|wlan)*([^.]).@(dhclient|dhcpcd|pump|udhcpc)
@(ath|wifi|wlan)*
")
      
      (name "ppp-interfaces")
      (value "ppp*")
      
      (name "all-interfaces")
      (value "*")))
  (resolvconf__default_interface_order (list
      
      (name "network-manager-interfaces")
      (copy_id_from "ethernet-interfaces")
      (value "NetworkManager")
      
      (name "wwan-interfaces")
      (value "@(hso|ww)*")
      
      (name "ethernet-interfaces")
      (value "em+([0-9])?(_+([0-9]))*
p+([0-9])p+([0-9])?(_+([0-9]))*
@(br|en|eth)*([^.]).inet6
@(br|en|eth)*([^.]).ip6.@(dhclient|dhcpcd|pump|udhcpc)
@(br|en|eth)*([^.]).inet
@(br|en|eth)*([^.]).@(dhclient|dhcpcd|pump|udhcpc)
@(br|en|eth)*
")
      
      (name "wireless-interfaces")
      (value "@(ath|wifi|wl|wlan)*([^.]).inet6
@(ath|wifi|wl|wlan)*([^.]).ip6.@(dhclient|dhcpcd|pump|udhcpc)
@(ath|wifi|wl|wlan)*([^.]).inet
@(ath|wifi|wl|wlan)*([^.]).@(dhclient|dhcpcd|pump|udhcpc)
@(ath|wifi|wl|wlan)*
")
      
      (name "ppp-interfaces")
      (value "@(ppp|sl)*")
      
      (name "vpn-interfaces")
      (copy_id_from "ppp-interfaces")
      (state (jinja "{{ \"present\"
               if (\"unbound\" in resolvconf__combined_services or
                   \"dnsmasq\" in resolvconf__combined_services or
                   \"bind\" in resolvconf__combined_services)
               else \"ignore\" }}"))
      
      (name "vlan-interfaces")
      (value "@(vlan|vxlan)*([^.]).inet6
@(vlan|vxlan)*([^.]).ip6.@(dhclient|dhcpcd|pump|udhcpc)
@(vlan|vxlan)*([^.]).inet
@(vlan|vxlan)*([^.]).@(dhclient|dhcpcd|pump|udhcpc)
@(vlan|vxlan)*
")
      (copy_id_from "vpn-interfaces")
      (weight "-10")
      
      (name "mesh-interfaces")
      (value "@(mesh)*([^.]).inet6
@(mesh)*([^.]).ip6.@(dhclient|dhcpcd|pump|udhcpc)
@(mesh)*([^.]).inet
@(mesh)*([^.]).@(dhclient|dhcpcd|pump|udhcpc)
@(mesh)*
")
      (copy_id_from "vpn-interfaces")
      (weight "-5")))
  (resolvconf__interface_order (list))
  (resolvconf__group_interface_order (list))
  (resolvconf__host_interface_order (list))
  (resolvconf__combined_interface_order (jinja "{{ resolvconf__original_interface_order
                                          + resolvconf__default_interface_order
                                          + resolvconf__interface_order
                                          + resolvconf__group_interface_order
                                          + resolvconf__host_interface_order }}"))
  (resolvconf__default_services (list
      (jinja "{{ \"dnsmasq\"
        if (ansible_local.dnsmasq.installed | d() | bool)
        else [] }}")
      (jinja "{{ \"unbound\"
        if (ansible_local.unbound.installed | d() | bool)
        else [] }}")
      (jinja "{{ \"bind\"
        if (ansible_local.bind.installed | d() | bool)
        else [] }}")))
  (resolvconf__services (list))
  (resolvconf__dependent_services (list))
  (resolvconf__combined_services (jinja "{{ q(\"flattened\",
                                     (resolvconf__default_services
                                      + resolvconf__services
                                      + resolvconf__dependent_services)) }}")))
