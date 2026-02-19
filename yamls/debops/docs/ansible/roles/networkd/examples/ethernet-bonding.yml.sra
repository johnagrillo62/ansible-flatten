(playbook "debops/docs/ansible/roles/networkd/examples/ethernet-bonding.yml"
  (networkd__host_units (list
      
      (name "30-bond1.network")
      (raw "[Match]
Name=bond1

[Network]
DHCP=ipv6
")
      (state "present")
      
      (name "30-bond1.netdev")
      (raw "[NetDev]
Name=bond1
Kind=bond
")
      (state "present")
      
      (name "30-bond1-dev1.network")
      (raw "[Match]
MACAddress=52:54:00:e9:64:41

[Network]
Bond=bond1
")
      (state "present")
      
      (name "30-bond1-dev2.network")
      (raw "[Match]
MACAddress=52:54:00:e9:64:42

[Network]
Bond=bond1
")
      (state "present"))))
