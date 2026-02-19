(playbook "kubespray/roles/container-engine/cri-o/molecule/default/converge.yml"
    (play
    (name "Converge")
    (hosts "all")
    (become "true")
    (roles
      
        (role "kubespray_defaults")
      
        (role "container-engine/cri-o"))))
