(playbook "kubespray/tests/files/almalinux9-crio.yml"
  (cloud_image "almalinux-9")
  (container_manager "crio")
  (auto_renew_certificates "true"))
