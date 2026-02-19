(playbook "kubespray/roles/bootstrap_os/molecule/default/converge.yml"
    (play
    (name "Converge")
    (hosts "all")
    (gather_facts "false")
    (become "true")
    (roles
      
        (role "bootstrap_os"))))
