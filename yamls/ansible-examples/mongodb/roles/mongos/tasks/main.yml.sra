(playbook "ansible-examples/mongodb/roles/mongos/tasks/main.yml"
  (tasks
    (task "Create the mongos startup file"
      (template "src=mongos.j2 dest=/etc/init.d/mongos mode=0655"))
    (task "Create the mongos configuration file"
      (template "src=mongos.conf.j2 dest=/etc/mongos.conf"))
    (task "Copy the keyfile for authentication"
      (copy "src=roles/mongod/files/secret dest=" (jinja "{{ mongodb_datadir_prefix }}") "/secret owner=mongod group=mongod mode=0400"))
    (task "Start the mongos service"
      (command "creates=/var/lock/subsys/mongos /etc/init.d/mongos start"))
    (task "pause"
      (pause "seconds=20"))
    (task "copy the file for shard test"
      (template "src=testsharding.j2 dest=/tmp/testsharding.js"))
    (task "copy the file enable  sharding"
      (template "src=enablesharding.j2 dest=/tmp/enablesharding.js"))))
