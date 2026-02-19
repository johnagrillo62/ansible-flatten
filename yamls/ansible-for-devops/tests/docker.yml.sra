(playbook "ansible-for-devops/tests/docker.yml"
  (list
    
    (hosts "all")
    (vars 
      (pip_install_packages (list
          "docker")))
    (pre_tasks (list
        
        (name "Update the apt cache so we can install ufw.")
        (apt "update_cache=yes cache_valid_time=600")))
    (roles (list
        "geerlingguy.docker"
        "geerlingguy.pip"))
    
    (import_playbook "../docker/main.yml")))
