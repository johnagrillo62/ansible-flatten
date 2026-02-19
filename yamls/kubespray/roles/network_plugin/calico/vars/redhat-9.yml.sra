(playbook "kubespray/roles/network_plugin/calico/vars/redhat-9.yml"
  (calico_wireguard_packages (list
      "wireguard-tools")))
