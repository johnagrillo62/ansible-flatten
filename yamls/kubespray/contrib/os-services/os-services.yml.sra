(playbook "kubespray/contrib/os-services/os-services.yml"
    (play
    (name "Disable firewalld/ufw")
    (hosts "all")
    (roles
      
        (role "prepare"))))
