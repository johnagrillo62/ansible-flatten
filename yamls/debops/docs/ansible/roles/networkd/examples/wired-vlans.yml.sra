(playbook "debops/docs/ansible/roles/networkd/examples/wired-vlans.yml"
  (networkd__host_units (list
      
      (name "20-bridge-slave-interface-vlan.network")
      (raw "[Match]
Name=enp2s0

[Network]
Bridge=bridge0

[BridgeVLAN]
VLAN=1-32
PVID=42
EgressUntagged=42

[BridgeVLAN]
VLAN=100-200

[BridgeVLAN]
EgressUntagged=300-400
")
      (state "present"))))
