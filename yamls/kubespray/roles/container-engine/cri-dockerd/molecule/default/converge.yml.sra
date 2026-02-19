(playbook "kubespray/roles/container-engine/cri-dockerd/molecule/default/converge.yml"
    (play
    (name "Converge")
    (hosts "all")
    (become "true")
    (vars
      (container_manager "docker"))
    (roles
      
        (role "kubespray_defaults")
      
        (role "container-engine/cri-dockerd"))))
