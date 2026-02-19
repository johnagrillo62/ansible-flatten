(playbook "ansible-for-devops/deployments-rolling/requirements.yml"
    (play
    (roles
      
        (name "geerlingguy.firewall")
      
        (name "geerlingguy.nodejs")
      
        (name "geerlingguy.git"))))
