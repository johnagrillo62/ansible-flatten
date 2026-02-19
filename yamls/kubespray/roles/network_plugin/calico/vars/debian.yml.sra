(playbook "kubespray/roles/network_plugin/calico/vars/debian.yml"
  (calico_wireguard_packages (list
      "wireguard")))
