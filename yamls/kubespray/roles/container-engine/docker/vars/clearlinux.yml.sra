(playbook "kubespray/roles/container-engine/docker/vars/clearlinux.yml"
  (docker_package_info 
    (pkgs (list
        "containers-basic"))))
