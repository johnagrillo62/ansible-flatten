(playbook "kubespray/tests/files/almalinux9-docker.yml"
  (cloud_image "almalinux-9")
  (vm_memory "3072")
  (container_manager "docker")
  (etcd_deployment_type "docker")
  (resolvconf_mode "docker_dns"))
