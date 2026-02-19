(playbook "kubespray/tests/files/fedora39-crio.yml"
  (cloud_image "fedora-39")
  (container_manager "crio")
  (auto_renew_certificates "true")
  (preinstall_selinux_state "enforcing"))
