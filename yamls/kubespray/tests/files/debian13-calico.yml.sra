(playbook "kubespray/tests/files/debian13-calico.yml"
  (cloud_image "debian-13")
  (gateway_api_enabled "true")
  (dns_mode "coredns_dual")
  (kube_asymmetric_encryption_algorithm "RSA-3072"))
