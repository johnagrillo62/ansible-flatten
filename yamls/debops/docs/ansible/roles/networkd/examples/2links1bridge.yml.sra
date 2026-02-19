(playbook "debops/docs/ansible/roles/networkd/examples/2links1bridge.yml"
  (bridge_if "bridge0")
  (networkd__group_units (list
      
      (name "bridge0.netdev")
      (raw "[NetDev]
Name=" (jinja "{{ bridge_if }}") "
Kind=bridge
")
      (state "present")
      
      (name "25-bridge-static.network")
      (raw "[Match]
Name=" (jinja "{{ bridge_if }}") "

[Network]
Address=192.0.2.15/24
Gateway=192.0.2.1
DNS=192.0.2.1
")
      (state "present")
      
      (name "25-bridge-slave-interface-1.network")
      (raw "[Match]
Name=enp2s0

[Network]
Bridge=" (jinja "{{ bridge_if }}") "
")
      (state "present")
      
      (name "25-bridge-slave-interface-2.network")
      (raw "[Match]
Name=wlp3s0

[Network]
Bridge=" (jinja "{{ bridge_if }}") "
")
      (state "present"))))
