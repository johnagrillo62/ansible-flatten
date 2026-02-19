(playbook "ansible-for-devops/lamp-infrastructure/playbooks/www/main.yml"
    (play
    (hosts "lamp_www")
    (become "yes")
    (vars_files (list
        "vars.yml"))
    (roles
      "geerlingguy.firewall"
      "geerlingguy.repo-epel"
      "geerlingguy.apache"
      "geerlingguy.php"
      "geerlingguy.php-mysql"
      "geerlingguy.php-memcached")
    (tasks
      (task "Remove the Apache test page."
        (file 
          (path "/var/www/html/index.html")
          (state "absent")))
      (task "Copy our fancy server-specific home page."
        (template 
          (src "templates/index.php.j2")
          (dest "/var/www/html/index.php")))
      (task "Ensure required SELinux dependency is installed."
        (package 
          (name "libsemanage-python")
          (state "present")))
      (task "Configure SELinux to allow HTTPD connections."
        (seboolean 
          (name (jinja "{{ item }}"))
          (state "true")
          (persistent "true"))
        (with_items (list
            "httpd_can_network_connect_db"
            "httpd_can_network_memcache"))
        (when "ansible_selinux.status == 'enabled'")))))
