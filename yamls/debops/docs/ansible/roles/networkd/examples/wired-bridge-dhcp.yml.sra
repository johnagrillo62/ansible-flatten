(playbook "debops/docs/ansible/roles/networkd/examples/wired-bridge-dhcp.yml"
  (networkd__units (list
      
      (name "br0.netdev")
      (raw "[NetDev]
Name=br0
Kind=bridge
")
      (state "present")
      
      (name "br0.network")
      (raw "[Match]
Name=br0

[Network]
DHCP=yes

[DHCPv4]
UseDomains=true
")
      (state "present")
      
      (name "enp1s0.network")
      (raw "[Match]
Name=enp1s0

[Network]
Bridge=br0
")
      (state "present"))))
