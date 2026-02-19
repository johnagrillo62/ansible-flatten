(playbook "kubespray/roles/container-engine/containerd/meta/main.yml"
  (dependencies (list
      
      (role "container-engine/containerd-common")
      
      (role "container-engine/runc")
      
      (role "container-engine/crictl")
      
      (role "container-engine/nerdctl"))))
