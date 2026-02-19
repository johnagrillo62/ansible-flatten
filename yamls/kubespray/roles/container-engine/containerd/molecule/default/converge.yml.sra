(playbook "kubespray/roles/container-engine/containerd/molecule/default/converge.yml"
    (play
    (name "Converge")
    (hosts "all")
    (become "true")
    (vars
      (container_manager "containerd"))
    (roles
      
        (role "kubespray_defaults")
      
        (role "container-engine/containerd"))))
