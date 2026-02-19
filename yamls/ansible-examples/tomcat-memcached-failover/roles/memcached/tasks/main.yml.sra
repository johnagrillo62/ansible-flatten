(playbook "ansible-examples/tomcat-memcached-failover/roles/memcached/tasks/main.yml"
  (tasks
    (task "Install memcached"
      (yum "name=memcached state=present"))
    (task "Deliver configuration file"
      (template "src=memcached.conf.j2 dest=/etc/sysconfig/memcached backup=yes")
      (notify "restart memcached"))
    (task "Deliver init script"
      (template "src=init.sh.j2 dest=/etc/init.d/memcached mode=0755")
      (notify "restart memcached"))
    (task "Start memcached service"
      (service "name=memcached state=started enabled=yes"))))
