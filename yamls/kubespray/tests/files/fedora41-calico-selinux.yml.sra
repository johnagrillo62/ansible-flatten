(playbook "kubespray/tests/files/fedora41-calico-selinux.yml"
  (cloud_image "fedora-41")
  (auto_renew_certificates "true")
  (preinstall_selinux_state "enforcing"))
