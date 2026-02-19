(playbook "ansible-for-devops/tests/https-nginx-proxy.yml"
  (list
    
    (hosts "all")
    (tasks (list
        
        (name "Ensure apt cache is updated.")
        (apt "update_cache=true cache_valid_time=600")))
    
    (import_playbook "../https-nginx-proxy/provisioning/main.yml")))
