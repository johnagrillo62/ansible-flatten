(playbook "kubespray/tests/files/almalinux9-kube-ovn.yml"
  (cloud_image "almalinux-9")
  (vm_memory "3072")
  (kube_network_plugin "kube-ovn"))
