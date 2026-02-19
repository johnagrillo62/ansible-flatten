(playbook "ansible-examples/mongodb/playbooks/testsharding.yml"
    (play
    (hosts "$servername")
    (remote_user "root")
    (tasks
      (task "Create a new database and user"
        (mongodb_user "login_user=admin login_password=${mongo_admin_pass} login_port=${mongos_port} database=test user=admin password=${mongo_admin_pass} state=present"))
      (task "Pause for the user to get created and replicated"
        (pause "minutes=3"))
      (task "Execute the collection creation script"
        (command "/usr/bin/mongo localhost:${mongos_port}/test -u admin -p ${mongo_admin_pass} /tmp/testsharding.js"))
      (task "Enable sharding on the database and collection"
        (command "/usr/bin/mongo localhost:${mongos_port}/admin -u admin -p ${mongo_admin_pass} /tmp/enablesharding.js")))))
