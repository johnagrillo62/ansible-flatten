(playbook "kubespray/roles/container-engine/gvisor/molecule/default/converge.yml"
    (play
    (name "Converge")
    (hosts "all")
    (become "true")
    (vars
      (gvisor_enabled "true")
      (container_manager "containerd"))
    (roles
      
        (role "kubespray_defaults")
      
        (role "container-engine/containerd")
      
        (role "container-engine/gvisor"))))
