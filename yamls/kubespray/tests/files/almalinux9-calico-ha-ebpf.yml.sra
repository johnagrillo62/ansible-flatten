(playbook "kubespray/tests/files/almalinux9-calico-ha-ebpf.yml"
  (cloud_image "almalinux-9")
  (mode "ha")
  (vm_memory "3072")
  (calico_bpf_enabled "true")
  (loadbalancer_apiserver_localhost "true")
  (auto_renew_certificates "true"))
