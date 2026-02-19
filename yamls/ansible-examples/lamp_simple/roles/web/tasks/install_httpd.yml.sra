(playbook "ansible-examples/lamp_simple/roles/web/tasks/install_httpd.yml"
  (tasks
    (task "Install http and php etc"
      (yum 
        (name (jinja "{{ item }}"))
        (state "present"))
      (with_items (list
          "httpd"
          "php"
          "php-mysql"
          "git"
          "libsemanage-python"
          "libselinux-python")))
    (task "insert iptables rule for httpd"
      (lineinfile 
        (dest "/etc/sysconfig/iptables")
        (create "yes")
        (state "present")
        (regexp (jinja "{{ httpd_port }}"))
        (insertafter "^:OUTPUT ")
        (line "-A INPUT -p tcp  --dport " (jinja "{{ httpd_port }}") " -j  ACCEPT"))
      (notify "restart iptables"))
    (task "http service state"
      (service 
        (name "httpd")
        (state "started")
        (enabled "yes")))
    (task "Configure SELinux to allow httpd to connect to remote database"
      (seboolean 
        (name "httpd_can_network_connect_db")
        (state "true")
        (persistent "yes"))
      (when "sestatus.rc != 0"))))
