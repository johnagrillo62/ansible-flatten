(playbook "kubespray/roles/network_plugin/calico/vars/rocky-9.yml"
  (calico_wireguard_packages (list
      "wireguard-tools")))
