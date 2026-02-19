(playbook "ansible-for-devops/tests/galaxy-role-servers.yml"
  (list
    
    (hosts "all")
    (pre_tasks (list
        
        (name "Update the apt cache.")
        (apt "update_cache=yes cache_valid_time=600")))
    
    (import_playbook "../galaxy-role-servers/lamp.yml")
    
    (import_playbook "../galaxy-role-servers/solr.yml")))
