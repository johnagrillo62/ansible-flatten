(playbook "ansible-examples/lamp_simple/roles/db/tasks/main.yml"
  (tasks
    (task "Install Mysql package"
      (yum 
        (name (jinja "{{ item }}"))
        (state "installed"))
      (with_items (list
          "mysql-server"
          "MySQL-python"
          "libselinux-python"
          "libsemanage-python")))
    (task "Configure SELinux to start mysql on any port"
      (seboolean 
        (name "mysql_connect_any")
        (state "true")
        (persistent "yes"))
      (when "sestatus.rc != 0"))
    (task "Create Mysql configuration file"
      (template 
        (src "my.cnf.j2")
        (dest "/etc/my.cnf"))
      (notify (list
          "restart mysql")))
    (task "Start Mysql Service"
      (service 
        (name "mysqld")
        (state "started")
        (enabled "yes")))
    (task "insert iptables rule"
      (lineinfile 
        (dest "/etc/sysconfig/iptables")
        (state "present")
        (regexp (jinja "{{ mysql_port }}"))
        (insertafter "^:OUTPUT ")
        (line "-A INPUT -p tcp  --dport " (jinja "{{ mysql_port }}") " -j  ACCEPT"))
      (notify "restart iptables"))
    (task "Create Application Database"
      (mysql_db 
        (name (jinja "{{ dbname }}"))
        (state "present")))
    (task "Create Application DB User"
      (mysql_user 
        (name (jinja "{{ dbuser }}"))
        (password (jinja "{{ upassword }}"))
        (priv "*.*:ALL")
        (host "%")
        (state "present")))))
