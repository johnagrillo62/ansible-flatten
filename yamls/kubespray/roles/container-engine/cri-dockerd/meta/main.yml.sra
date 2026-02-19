(playbook "kubespray/roles/container-engine/cri-dockerd/meta/main.yml"
  (dependencies (list
      
      (role "container-engine/docker")
      
      (role "container-engine/crictl"))))
