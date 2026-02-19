(playbook "ansible-for-devops/deployments-balancer/requirements.yml"
    (play
    (roles
      
        (name "geerlingguy.firewall")
      
        (name "geerlingguy.haproxy")
      
        (name "geerlingguy.apache"))))
