(playbook "ansible-examples/lamp_haproxy/roles/nagios/tasks/main.yml"
  (tasks
    (task "install nagios"
      (yum "pkg=" (jinja "{{ item }}") " state=present")
      (with_items (list
          "nagios"
          "nagios-plugins"
          "nagios-plugins-nrpe"
          "nagios-plugins-ping"
          "nagios-plugins-ssh"
          "nagios-plugins-http"
          "nagios-plugins-mysql"
          "nagios-devel"))
      (notify "restart httpd"))
    (task "create nagios config dir"
      (file "path=/etc/nagios/ansible-managed state=directory"))
    (task "configure nagios"
      (copy "src=nagios.cfg dest=/etc/nagios/nagios.cfg")
      (notify "restart nagios"))
    (task "configure localhost monitoring"
      (copy "src=localhost.cfg dest=/etc/nagios/objects/localhost.cfg")
      (notify "restart nagios"))
    (task "configure nagios services"
      (copy "src=ansible-managed-services.cfg dest=/etc/nagios/"))
    (task "create the nagios object files"
      (template "src=" (jinja "{{ item + \".j2\" }}") " dest=/etc/nagios/ansible-managed/" (jinja "{{ item }}"))
      (with_items (list
          "webservers.cfg"
          "dbservers.cfg"
          "lbservers.cfg"))
      (notify "restart nagios"))
    (task "start nagios"
      (service "name=nagios state=started enabled=yes"))))
