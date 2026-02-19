(playbook "ansible-examples/tomcat-memcached-failover/roles/tomcat/tasks/main.yml"
  (tasks
    (task "Install OpenJDK"
      (yum "name=java-1.7.0-openjdk state=present"))
    (task "Install Tomcat"
      (yum "name=tomcat state=present"))
    (task "Deliver configuration files for tomcat"
      (template "src=" (jinja "{{ item.src }}") " dest=" (jinja "{{ item.dest }}") " backup=yes")
      (with_items (list
          
          (src "default.j2")
          (dest "/etc/tomcat/default")
          
          (src "server.xml.j2")
          (dest "/etc/tomcat/server.xml")
          
          (src "context.xml.j2")
          (dest "/etc/tomcat/context.xml")))
      (notify "restart tomcat"))
    (task "Deliver libraries support memcached"
      (get_url "url=\"" (jinja "{{ item }}") "\" dest=/usr/share/tomcat/lib/")
      (with_items (list
          "http://repo1.maven.org/maven2/de/javakaffee/msm/memcached-session-manager/1.8.0/memcached-session-manager-1.8.0.jar"
          "http://repo1.maven.org/maven2/de/javakaffee/msm/memcached-session-manager-tc7/1.8.0/memcached-session-manager-tc7-1.8.0.jar"
          "https://spymemcached.googlecode.com/files/spymemcached-2.10.2.jar")))
    (task "Deploy sample app"
      (copy "src=msm-sample-webapp-1.0-SNAPSHOT.war dest=/var/lib/tomcat/webapps/ROOT.war owner=tomcat group=tomcat"))
    (task "Start tomcat service"
      (service "name=tomcat state=started enabled=yes"))))
