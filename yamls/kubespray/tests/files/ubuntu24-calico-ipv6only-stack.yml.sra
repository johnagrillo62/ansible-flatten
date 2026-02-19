(playbook "kubespray/tests/files/ubuntu24-calico-ipv6only-stack.yml"
  (cloud_image "ubuntu-2404")
  (ipv4_stack "false")
  (ipv6_stack "true")
  (kube_network_plugin "calico")
  (etcd_deployment_type "kubeadm")
  (kube_proxy_mode "iptables")
  (enable_nodelocaldns "false"))
