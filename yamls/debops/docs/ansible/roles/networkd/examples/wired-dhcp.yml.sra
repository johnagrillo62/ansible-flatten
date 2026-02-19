(playbook "debops/docs/ansible/roles/networkd/examples/wired-dhcp.yml"
  (networkd__units (list
      
      (name "wired-dhcp.network")
      (comment "Configure any wired Ethernet interface via DHCP")
      (raw "[Match]
Name=en*

[Network]
DHCP=yes

[DHCPv4]
UseDomains=true
")
      (state "present"))))
