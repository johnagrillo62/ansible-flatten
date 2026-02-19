(playbook "kubespray/tests/files/fedora41-crio.yml"
  (cloud_image "fedora-41")
  (container_manager "crio")
  (auto_renew_certificates "true"))
