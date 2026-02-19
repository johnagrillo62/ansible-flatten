(playbook "ansible-for-devops/tests/jenkins.yml"
  (list
    
    (hosts "all")
    (vars 
      (firewall_enable_ipv6 "false"))
    (tasks (list
        
        (name "Update the apt cache so we can install ufw.")
        (apt "update_cache=yes cache_valid_time=600")))
    
    (import_playbook "../jenkins/provision.yml")
    (vars 
      (firewall_enable_ipv6 "false"))))
