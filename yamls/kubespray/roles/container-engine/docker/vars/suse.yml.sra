(playbook "kubespray/roles/container-engine/docker/vars/suse.yml"
  (docker_package_info 
    (state "latest")
    (pkgs (list
        "docker"
        "containerd"))))
