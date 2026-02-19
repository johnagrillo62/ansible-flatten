(playbook "ansible-for-devops/deployments-rolling/playbooks/main.yml"
  (list
    
    (import_playbook "provision.yml")
    
    (import_playbook "deploy.yml")))
