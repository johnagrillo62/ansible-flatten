(playbook "ansible-for-devops/molecule/main.yml"
    (play
    (name "Install Apache.")
    (hosts "all")
    (become "true")
    (vars
      (apache_package "apache2")
      (apache_service "apache2"))
    (handlers
      (task "restart apache"
        (ansible.builtin.service 
          (name (jinja "{{ apache_service }}"))
          (state "restarted"))))
    (pre_tasks
      (task "Override Apache vars for Red Hat."
        (ansible.builtin.set_fact 
          (apache_package "httpd")
          (apache_service "httpd"))
        (when "ansible_os_family == 'RedHat'")))
    (tasks
      (task "Ensure Apache is installed."
        (ansible.builtin.package 
          (name (jinja "{{ apache_package }}"))
          (state "present")))
      (task "Copy a web page."
        (ansible.builtin.copy 
          (content "<html>
<head><title>Hello world!</title></head>
<body>Hello world!</body>
</html>
")
          (dest "/var/www/html/index.html")
          (mode "0664"))
        (notify "restart apache"))
      (task "Ensure Apache is running and starts at boot."
        (ansible.builtin.service 
          (name (jinja "{{ apache_service }}"))
          (state "started")
          (enabled "true"))))))
