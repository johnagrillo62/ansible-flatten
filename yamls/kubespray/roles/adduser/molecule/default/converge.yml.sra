(playbook "kubespray/roles/adduser/molecule/default/converge.yml"
    (play
    (name "Converge")
    (hosts "all")
    (become "true")
    (gather_facts "false")
    (roles
      
        (role "adduser"))
    (vars
      (user 
        (name "foo")))))
