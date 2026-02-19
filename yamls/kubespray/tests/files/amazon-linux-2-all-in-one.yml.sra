(playbook "kubespray/tests/files/amazon-linux-2-all-in-one.yml"
  (cloud_image "amazon-linux-2")
  (mode "all-in-one")
  (kubeadm_ignore_preflight_errors (list
      "SystemVerification")))
