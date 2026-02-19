(playbook "kubespray/roles/network_plugin/calico/vars/amazon.yml"
  (calico_wireguard_repo "https://download.copr.fedorainfracloud.org/results/jdoss/wireguard/epel-7-$basearch/")
  (calico_wireguard_packages (list
      "wireguard-dkms"
      "wireguard-tools")))
