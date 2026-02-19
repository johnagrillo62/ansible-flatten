(playbook "ansible-for-devops/tests/nodejs.yml"
  (list
    
    (hosts "all")
    (tasks (list
        
        (name "Install firewalld so we can disable it in the playbook.")
        (dnf "name=firewalld state=present")))
    
    (import_playbook "../nodejs/provisioning/playbook.yml")))
