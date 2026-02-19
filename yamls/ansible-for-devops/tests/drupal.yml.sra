(playbook "ansible-for-devops/tests/drupal.yml"
  (list
    
    (hosts "all")
    (tasks (list
        
        (name "Update the apt cache so we can install ufw.")
        (apt "update_cache=yes cache_valid_time=600")
        
        (name "Install required test dependencies.")
        (apt 
          (name (list
              "ufw"
              "dirmngr"))
          (state "present"))))
    
    (import_playbook "../drupal/provisioning/playbook.yml")))
