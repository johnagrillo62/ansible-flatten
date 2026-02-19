(playbook "ansible-for-devops/lamp-infrastructure/provision.yml"
  (list
    
    (import_playbook "provisioners/digitalocean.yml")
    
    (import_playbook "configure.yml")))
