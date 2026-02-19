(playbook "kubespray/tests/files/ubuntu24-calico-etcd-kubeadm.yml"
  (cloud_image "ubuntu-2404")
  (etcd_deployment_type "kubeadm")
  (kube_proxy_mode "iptables")
  (enable_nodelocaldns "false")
  (remove_anonymous_access "true"))
