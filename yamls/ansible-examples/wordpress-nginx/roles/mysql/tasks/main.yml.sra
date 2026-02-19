(playbook "ansible-examples/wordpress-nginx/roles/mysql/tasks/main.yml"
  (tasks
    (task "Install Mysql package"
      (yum "name=" (jinja "{{ item }}") " state=present")
      (with_items (list
          "mysql-server"
          "MySQL-python"
          "libselinux-python"
          "libsemanage-python")))
    (task "Configure SELinux to start mysql on any port"
      (seboolean "name=mysql_connect_any state=true persistent=yes")
      (when "ansible_selinux.status == \"enabled\""))
    (task "Create Mysql configuration file"
      (template "src=my.cnf.j2 dest=/etc/my.cnf")
      (notify (list
          "restart mysql")))
    (task "Start Mysql Service"
      (service "name=mysqld state=started enabled=yes"))))
