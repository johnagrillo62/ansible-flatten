(playbook "kubespray/tests/files/fedora39-calico-selinux.yml"
  (cloud_image "fedora-39")
  (auto_renew_certificates "true")
  (preinstall_selinux_state "enforcing"))
