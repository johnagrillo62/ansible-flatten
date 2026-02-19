(playbook "kubespray/tests/files/fedora40-docker-calico.yml"
  (cloud_image "fedora-40")
  (auto_renew_certificates "true")
  (container_manager "docker")
  (etcd_deployment_type "docker"))
