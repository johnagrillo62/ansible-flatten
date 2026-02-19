(playbook "ansible-for-devops/tests/elk.yml"
  (list
    
    (hosts "all")
    (pre_tasks (list
        
        (name "Update the apt cache.")
        (apt "update_cache=yes cache_valid_time=600")))
    (tasks (list
        
        (add_host 
          (name "localhost")
          (groups "logs"))
        (changed_when "false")))
    
    (import_playbook "../elk/provisioning/elk/main.yml")))
