(playbook "ansible-for-devops/tests/deployments.yml"
  (list
    
    (hosts "all")
    (pre_tasks (list
        
        (name "Update the apt cache.")
        (apt "update_cache=yes cache_valid_time=600")))
    
    (import_playbook "../deployments/playbooks/provision.yml")
    
    (import_playbook "../deployments/playbooks/deploy.yml")))
