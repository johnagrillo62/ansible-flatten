(playbook "kubespray/roles/container-engine/youki/molecule/default/converge.yml"
    (play
    (name "Converge")
    (hosts "all")
    (become "true")
    (vars
      (youki_enabled "true")
      (container_manager "crio"))
    (roles
      
        (role "kubespray_defaults")
      
        (role "container-engine/cri-o")
      
        (role "container-engine/youki"))))
