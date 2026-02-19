(playbook "debops/ansible/roles/networkd/defaults/main.yml"
  (networkd__enabled (jinja "{{ True
                       if (ansible_service_mgr == \"systemd\")
                       else False }}"))
  (networkd__unattended_restart (jinja "{{ True
                                  if ((ansible_local.networkd.state | d()) == \"enabled\")
                                  else False }}"))
  (networkd__deploy_state "absent")
  (networkd__version (jinja "{{ ansible_local.networkd.version | d(\"0\") }}"))
  (networkd__default_configuration (list
      
      (name "SpeedMeter")
      (value "False")
      (state "init")
      
      (name "SpeedMeterIntervalSec")
      (value "10sec")
      (state "init")
      
      (name "ManageForeignRoutes")
      (value "True")
      (state "init")))
  (networkd__configuration (list))
  (networkd__group_configuration (list))
  (networkd__host_configuration (list))
  (networkd__combined_configuration (jinja "{{ networkd__default_configuration
                                     + networkd__configuration
                                     + networkd__group_configuration
                                     + networkd__host_configuration }}"))
  (networkd__dhcp_default_configuration (list
      
      (name "DUIDType")
      (value "vendor")
      (state "init")
      
      (name "DUIDRawData")
      (value "")
      (state "init")))
  (networkd__dhcp_configuration (list))
  (networkd__dhcp_group_configuration (list))
  (networkd__dhcp_host_configuration (list))
  (networkd__dhcp_combined_configuration (jinja "{{ networkd__dhcp_default_configuration
                                          + networkd__dhcp_configuration
                                          + networkd__dhcp_group_configuration
                                          + networkd__dhcp_host_configuration }}"))
  (networkd__default_units (list
      
      (name "wired-dhcp.network")
      (comment "Configure any wired Ethernet interface via DHCP")
      (raw "[Match]
Name=e*

[Network]
DHCP=yes
MulticastDNS=yes
LLDP=yes
EmitLLDP=yes

[DHCPv4]
UseDomains=true
")
      (state "present")))
  (networkd__units (list))
  (networkd__group_units (list))
  (networkd__host_units (list))
  (networkd__dependent_units (list))
  (networkd__combined_units (jinja "{{ networkd__default_units
                              + networkd__dependent_units
                              + networkd__units
                              + networkd__group_units
                              + networkd__host_units }}")))
