(playbook "kubespray/tests/files/rockylinux9-calico.yml"
  (cloud_image "rockylinux-9")
  (vm_memory "3072")
  (metrics_server_enabled "true")
  (loadbalancer_apiserver_type "haproxy"))
