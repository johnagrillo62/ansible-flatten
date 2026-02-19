(playbook "kubespray/roles/container-engine/kata-containers/molecule/default/converge.yml"
    (play
    (name "Converge")
    (hosts "all")
    (become "true")
    (vars
      (kata_containers_enabled "true")
      (container_manager "containerd"))
    (roles
      
        (role "kubespray_defaults")
      
        (role "container-engine/containerd")
      
        (role "container-engine/kata-containers"))))
