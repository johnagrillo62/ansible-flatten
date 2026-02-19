(playbook "ansible-examples/lamp_simple_rhel7/roles/web/tasks/install_httpd.yml"
  (tasks
    (task "Install httpd and php"
      (yum "name=" (jinja "{{ item }}") " state=present")
      (with_items (list
          "httpd"
          "php"
          "php-mysql")))
    (task "Install web role specific dependencies"
      (yum "name=" (jinja "{{ item }}") " state=installed")
      (with_items (list
          "git")))
    (task "Start firewalld"
      (service "name=firewalld state=started enabled=yes"))
    (task "insert firewalld rule for httpd"
      (firewalld "port=" (jinja "{{ httpd_port }}") "/tcp permanent=true state=enabled immediate=yes"))
    (task "http service state"
      (service "name=httpd state=started enabled=yes"))
    (task "Configure SELinux to allow httpd to connect to remote database"
      (seboolean "name=httpd_can_network_connect_db state=true persistent=yes"))))
