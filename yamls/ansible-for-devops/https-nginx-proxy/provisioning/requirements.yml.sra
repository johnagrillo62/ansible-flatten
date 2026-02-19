(playbook "ansible-for-devops/https-nginx-proxy/provisioning/requirements.yml"
    (play
    (roles
      
        (name "geerlingguy.firewall")
      
        (name "geerlingguy.pip")
      
        (name "geerlingguy.nginx"))))
