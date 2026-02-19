(playbook "kubespray/roles/network_plugin/calico/vars/opensuse.yml"
  (calico_wireguard_packages (list
      "wireguard-tools")))
