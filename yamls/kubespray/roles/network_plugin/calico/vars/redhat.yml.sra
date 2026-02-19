(playbook "kubespray/roles/network_plugin/calico/vars/redhat.yml"
  (calico_wireguard_packages (list
      "wireguard-dkms"
      "wireguard-tools")))
