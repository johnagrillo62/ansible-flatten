(playbook "ansible-for-devops/https-nginx-proxy/provisioning/main.yml"
    (play
    (hosts "all")
    (vars_files (list
        "vars/main.yml"))
    (pre_tasks
      (task "Ensure apt cache is updated."
        (apt "update_cache=true cache_valid_time=600"))
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
      (task "Start simple python webserver on port 8080."
        (shell "python3 -m http.server 8080 --directory " (jinja "{{ nginx_docroot }}") " &
")
        (async "45")
        (poll "0")
        (changed_when "false"))
      (task "Copy Nginx server configuration in place."
        (template 
          (src "templates/https.test.conf.j2")
          (dest "/etc/nginx/sites-enabled/https.test.conf")
          (mode "0644"))
        (notify "restart nginx")))))
