(playbook "ansible-for-devops/https-self-signed/provisioning/main.yml"
    (play
    (hosts "all")
    (vars_files (list
        "vars/main.yml"))
    (pre_tasks
      (task "Ensure apt cache is updated."
        (apt "update_cache=yes cache_valid_time=600"))
      (task "Install dependency for pyopenssl."
        (apt "name=libssl-dev state=present")))
    (roles
      "geerlingguy.firewall"
      "geerlingguy.pip"
      "geerlingguy.nginx")
    (tasks
      (task
        (import_tasks "tasks/self-signed-cert.yml"))
      (task "Ensure docroot exists."
        (file 
          (path (jinja "{{ nginx_docroot }}"))
          (state "directory")))
      (task "Copy example index.html file in place."
        (copy 
          (src "files/index.html")
          (dest (jinja "{{ nginx_docroot }}") "/index.html")
          (mode "0755")))
      (task "Copy Nginx server configuration in place."
        (template 
          (src "templates/https.test.conf.j2")
          (dest "/etc/nginx/sites-enabled/https.test.conf")
          (mode "0644"))
        (notify "restart nginx")))))
