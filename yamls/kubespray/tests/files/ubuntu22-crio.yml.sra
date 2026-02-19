(playbook "kubespray/tests/files/ubuntu22-crio.yml"
  (cloud_image "ubuntu-2204")
  (container_manager "crio")
  (download_localhost "false")
  (download_run_once "true"))
