(playbook "ansible-for-devops/tests/includes.yml"
  (list
    
    (hosts "all")
    (tasks (list
        
        (name "Update the apt cache so we can install ufw.")
        (apt "update_cache=yes cache_valid_time=600")
        
        (name "Install ufw so we can disable it in the playbook.")
        (apt "name=ufw state=present")))
    
    (import_playbook "../includes/provisioning/playbook.yml")))
