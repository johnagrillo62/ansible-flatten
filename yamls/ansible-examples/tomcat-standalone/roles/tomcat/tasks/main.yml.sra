(playbook "ansible-examples/tomcat-standalone/roles/tomcat/tasks/main.yml"
  (tasks
    (task "Install Java 1.7"
      (yum "name=java-1.7.0-openjdk state=present"))
    (task "add group \"tomcat\""
      (group "name=tomcat"))
    (task "add user \"tomcat\""
      (user "name=tomcat group=tomcat home=/usr/share/tomcat createhome=no")
      (become "True")
      (become_method "sudo"))
    (task "Download Tomcat"
      (get_url "url=http://archive.apache.org/dist/tomcat/tomcat-7/v7.0.61/bin/apache-tomcat-7.0.61.tar.gz dest=/opt/apache-tomcat-7.0.61.tar.gz"))
    (task "Extract archive"
      (command "chdir=/usr/share /bin/tar xvf /opt/apache-tomcat-7.0.61.tar.gz -C /opt/ creates=/opt/apache-tomcat-7.0.61"))
    (task "Symlink install directory"
      (file "src=/opt/apache-tomcat-7.0.61 path=/usr/share/tomcat state=link"))
    (task "Change ownership of Tomcat installation"
      (file "path=/usr/share/tomcat/ owner=tomcat group=tomcat state=directory recurse=yes"))
    (task "Configure Tomcat server"
      (template "src=server.xml dest=/usr/share/tomcat/conf/")
      (notify "restart tomcat"))
    (task "Configure Tomcat users"
      (template "src=tomcat-users.xml dest=/usr/share/tomcat/conf/")
      (notify "restart tomcat"))
    (task "Install Tomcat init script"
      (copy "src=tomcat-initscript.sh dest=/etc/init.d/tomcat mode=0755"))
    (task "Start Tomcat"
      (service "name=tomcat state=started enabled=yes"))
    (task "deploy iptables rules"
      (template "src=iptables-save dest=/etc/sysconfig/iptables")
      (when "ansible_os_family == 'RedHat' and ansible_distribution_major_version == '6'")
      (notify "restart iptables"))
    (task "insert firewalld rule for tomcat http port"
      (firewalld "port=" (jinja "{{ http_port }}") "/tcp permanent=true state=enabled immediate=yes")
      (when "ansible_os_family == 'RedHat' and ansible_distribution_major_version == '7'"))
    (task "insert firewalld rule for tomcat https port"
      (firewalld "port=" (jinja "{{ https_port }}") "/tcp permanent=true state=enabled immediate=yes")
      (when "ansible_os_family == 'RedHat' and ansible_distribution_major_version == '7'"))
    (task "wait for tomcat to start"
      (wait_for "port=" (jinja "{{http_port}}")))))
