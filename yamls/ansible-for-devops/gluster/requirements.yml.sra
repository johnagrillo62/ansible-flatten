(playbook "ansible-for-devops/gluster/requirements.yml"
    (play
    (roles
      
        (name "geerlingguy.firewall")
      
        (name "geerlingguy.glusterfs"))))
