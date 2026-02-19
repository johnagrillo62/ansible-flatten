(playbook "ansible-for-devops/elk/provisioning/web/main.yml"
    (play
    (hosts "web")
    (gather_facts "yes")
    (vars_files (list
        "vars/main.yml"))
    (pre_tasks
      (task "Update apt cache if needed."
        (apt "update_cache=yes cache_valid_time=86400")))
    (roles
      "geerlingguy.nginx"
      "geerlingguy.filebeat")
    (tasks
      (task "Set up virtual host for testing."
        (copy 
          (src "files/example.conf")
          (dest "/etc/nginx/sites-enabled/example.conf")
          (owner "root")
          (group "root")
          (mode "0644"))
        (notify "restart nginx"))
      (task "Ensure logs server is in hosts file."
        (lineinfile 
          (dest "/etc/hosts")
          (regexp ".*logs\\.test$")
          (line "192.168.56.90 logs.test")
          (state "present"))))))
