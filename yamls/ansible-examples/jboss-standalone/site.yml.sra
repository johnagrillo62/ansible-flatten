(playbook "ansible-examples/jboss-standalone/site.yml"
    (play
    (hosts "all")
    (roles
      "jboss-standalone")))
