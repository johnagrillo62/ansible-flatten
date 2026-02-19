(playbook "ansible-for-devops/docker-flask/provisioning/main.yml"
    (play
    (hosts "all")
    (become "true")
    (vars
      (build_root "/vagrant/provisioning"))
    (pre_tasks
      (task "Update apt cache if needed."
        (apt "update_cache=yes cache_valid_time=3600")))
    (roles
      
        (role "geerlingguy.docker"))
    (tasks
      (task
        (import_tasks "setup.yml"))
      (task
        (import_tasks "docker.yml")))))
