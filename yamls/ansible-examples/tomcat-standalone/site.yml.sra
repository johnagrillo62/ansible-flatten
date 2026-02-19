(playbook "ansible-examples/tomcat-standalone/site.yml"
    (play
    (hosts "tomcat-servers")
    (remote_user "root")
    (become "yes")
    (become_method "sudo")
    (roles
      "selinux"
      "tomcat")))
