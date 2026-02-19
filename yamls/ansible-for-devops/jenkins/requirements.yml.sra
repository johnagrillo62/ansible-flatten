(playbook "ansible-for-devops/jenkins/requirements.yml"
    (play
    (roles
      
        (name "geerlingguy.firewall")
      
        (name "geerlingguy.pip")
      
        (name "geerlingguy.ansible")
      
        (name "geerlingguy.java")
      
        (name "geerlingguy.jenkins"))))
