(playbook "ansible-examples/jboss-standalone/deploy-application.yml"
    (play
    (hosts "all")
    (roles
      "java-app")))
