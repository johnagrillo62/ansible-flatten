(playbook "kubespray/roles/container-engine/docker/meta/main.yml"
  (dependencies (list
      
      (role "container-engine/containerd-common"))))
