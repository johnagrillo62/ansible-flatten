(playbook "kubespray/tests/files/fedora42-calico.yml"
  (cloud_image "fedora-42")
  (auto_renew_certificates "true")
  (preinstall_selinux_state "enforcing"))
