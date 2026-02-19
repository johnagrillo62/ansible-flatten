(playbook "ansible-for-devops/https-letsencrypt/requirements.yml"
    (play
    (roles
      
        (name "geerlingguy.firewall")
      
        (name "geerlingguy.certbot")
      
        (name "geerlingguy.nginx"))))
