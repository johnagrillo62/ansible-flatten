(playbook "ansible-for-devops/kubernetes/requirements.yml"
    (play
    (roles
      
        (name "geerlingguy.swap")
      
        (name "geerlingguy.docker")
      
        (name "geerlingguy.kubernetes"))
    (collections (list
        
        (name "community.kubernetes")))))
