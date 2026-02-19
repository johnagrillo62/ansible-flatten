(playbook "debops/docs/ansible/roles/networkd/examples/static-ip.yml"
  (networkd__units (list
      
      (name "50-static.network")
      (comment "Configure specific interface with static IP address")
      (raw "[Match]
Name=enp2s0

[Network]
Address=192.0.2.15/24
Gateway=192.0.2.1
")
      (state "present"))))
