(playbook "kubespray/tests/files/fedora39-calico-swap-selinux.yml"
  (cloud_image "fedora-39")
  (auto_renew_certificates "true")
  (preinstall_selinux_state "enforcing")
  (kubelet_fail_swap_on "false")
  (kube_feature_gates (list
      "NodeSwap=True")))
