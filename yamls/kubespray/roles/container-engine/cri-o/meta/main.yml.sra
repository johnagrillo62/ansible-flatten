(playbook "kubespray/roles/container-engine/cri-o/meta/main.yml"
  (dependencies (list
      
      (role "container-engine/crictl")
      
      (role "container-engine/skopeo"))))
