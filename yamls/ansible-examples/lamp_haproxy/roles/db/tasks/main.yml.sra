(playbook "ansible-examples/lamp_haproxy/roles/db/tasks/main.yml"
  (tasks
    (task "Install Mysql package"
      (yum "name=" (jinja "{{ item }}") " state=present")
      (with_items (list
          "mysql-server"
          "MySQL-python")))
    (task "Configure SELinux to start mysql on any port"
      (seboolean "name=mysql_connect_any state=true persistent=yes")
      (when "sestatus.rc != 0"))
    (task "Create Mysql configuration file"
      (template "src=my.cnf.j2 dest=/etc/my.cnf")
      (notify (list
          "restart mysql")))
    (task "Start Mysql Service"
      (service "name=mysqld state=started enabled=yes"))
    (task "Create Application Database"
      (mysql_db "name=" (jinja "{{ dbname }}") " state=present"))
    (task "Create Application DB User"
      (mysql_user "name=" (jinja "{{ dbuser }}") " password=" (jinja "{{ upassword }}") " priv=*.*:ALL host='%' state=present"))))
