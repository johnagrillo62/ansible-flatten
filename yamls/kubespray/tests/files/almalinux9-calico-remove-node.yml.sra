(playbook "kubespray/tests/files/almalinux9-calico-remove-node.yml"
  (cloud_image "almalinux-9")
  (mode "ha")
  (auto_renew_certificates "true"))
