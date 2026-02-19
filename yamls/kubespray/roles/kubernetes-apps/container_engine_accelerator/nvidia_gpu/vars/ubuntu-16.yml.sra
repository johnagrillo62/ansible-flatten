(playbook "kubespray/roles/kubernetes-apps/container_engine_accelerator/nvidia_gpu/vars/ubuntu-16.yml"
  (nvidia_driver_install_container (jinja "{{ nvidia_driver_install_ubuntu_container }}"))
  (nvidia_driver_install_supported "true"))
