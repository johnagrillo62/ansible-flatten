(playbook "ansible-examples/jboss-standalone/roles/java-app/tasks/main.yml"
  (tasks
    (task "Copy application WAR file to host"
      (copy 
        (src "jboss-helloworld.war")
        (dest "/tmp")))
    (task "Deploy HelloWorld to JBoss"
      (jboss 
        (deploy_path "/usr/share/jboss-as/standalone/deployments/")
        (src "/tmp/jboss-helloworld.war")
        (deployment "helloworld.war")
        (state "present")))
    (task "Copy application WAR file to host"
      (copy 
        (src "ticket-monster.war")
        (dest "/tmp")))
    (task "Deploy Ticket Monster to JBoss"
      (jboss 
        (deploy_path "/usr/share/jboss-as/standalone/deployments/")
        (src "/tmp/ticket-monster.war")
        (deployment "ticket-monster.war")
        (state "present")))))
