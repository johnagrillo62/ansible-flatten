(playbook "ansible-examples/wordpress-nginx_rhel7/roles/mariadb/tasks/main.yml"
  (tasks
    (task "Install MariaDB package"
      (yum "name=" (jinja "{{ item }}") " state=installed")
      (with_items (list
          "mariadb-server"
          "MySQL-python"
          "libselinux-python"
          "libsemanage-python")))
    (task "Configure SELinux to start mysql on any port"
      (seboolean "name=mysql_connect_any state=true persistent=yes"))
    (task "Create Mysql configuration file"
      (template "src=my.cnf.j2 dest=/etc/my.cnf")
      (notify (list
          "restart mariadb")))
    (task "Create MariaDB log file"
      (file "path=/var/log/mysqld.log state=touch owner=mysql group=mysql mode=0775"))
    (task "Start MariaDB Service"
      (service "name=mariadb state=started enabled=yes"))
    (task "insert firewalld rule"
      (firewalld "port=" (jinja "{{ mysql_port }}") "/tcp permanent=true state=enabled immediate=yes")
      (ignore_errors "yes"))))
