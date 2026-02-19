(playbook "kubespray/tests/files/ubuntu24-calico-dual-stack.yml"
  (cloud_image "ubuntu-2404")
  (ipv4_stack "true")
  (ipv6_stack "true"))
