(playbook "ansible-examples/tomcat-memcached-failover/site.yml"
    (play
    (hosts "all")
    (remote_user "root")
    (roles
      "common"))
    (play
    (hosts "lb_servers")
    (remote_user "root")
    (roles
      "lb-nginx"))
    (play
    (hosts "backend_servers")
    (remote_user "root")
    (roles
      "tomcat"))
    (play
    (hosts "memcached_servers")
    (remote_user "root")
    (roles
      "memcached")))
