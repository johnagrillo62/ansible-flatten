(playbook "kubespray/tests/files/almalinux9-calico-nodelocaldns-secondary.yml"
  (cloud_image "almalinux-9")
  (vm_memory "3072")
  (enable_nodelocaldns_secondary "true")
  (loadbalancer_apiserver_type "haproxy"))
