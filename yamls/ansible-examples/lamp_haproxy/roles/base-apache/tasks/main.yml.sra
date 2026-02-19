(playbook "ansible-examples/lamp_haproxy/roles/base-apache/tasks/main.yml"
  (tasks
    (task "Install http"
      (yum 
        (name (jinja "{{ item }}"))
        (state "present"))
      (with_items (list
          "httpd"
          "php"
          "php-mysql"
          "git")))
    (task "Configure SELinux to allow httpd to connect to remote database"
      (seboolean 
        (name "httpd_can_network_connect_db")
        (state "true")
        (persistent "yes"))
      (when "sestatus.rc != 0"))
    (task "http service state"
      (service 
        (name "httpd")
        (state "started")
        (enabled "yes")))))
