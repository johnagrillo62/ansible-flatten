(playbook "ansible-for-devops/tests/docker-flask.yml"
  (list
    
    (hosts "all")
    (pre_tasks (list
        
        (name "Update the apt cache.")
        (apt "update_cache=yes cache_valid_time=600")))
    (roles (list
        "geerlingguy.docker"))
    
    (import_playbook "../docker-flask/provisioning/main.yml")
    (vars 
      (build_root (jinja "{{ playbook_dir }}")))))
