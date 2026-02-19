(playbook "kubespray/tests/files/debian12-calico.yml"
  (cloud_image "debian-12")
  (dns_mode "coredns_dual")
  (kube_asymmetric_encryption_algorithm "RSA-3072"))
