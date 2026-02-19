(playbook "ansible-for-devops/https-self-signed/provisioning/requirements.yml"
    (play
    (roles
      
        (name "geerlingguy.firewall")
      
        (name "geerlingguy.pip")
      
        (name "geerlingguy.nginx"))))
