(playbook "ansible-examples/mongodb/roles/mongod/tasks/main.yml"
  (tasks
    (task "create data directory for mongodb"
      (file "path=" (jinja "{{ mongodb_datadir_prefix }}") "/mongo-" (jinja "{{ inventory_hostname }}") " state=directory owner=mongod group=mongod")
      (delegate_to (jinja "{{ item }}"))
      (with_items "groups.replication_servers"))
    (task "create log directory for mongodb"
      (file "path=/var/log/mongo state=directory owner=mongod group=mongod"))
    (task "create run directory for mongodb"
      (file "path=/var/run/mongo state=directory owner=mongod group=mongod"))
    (task "Create the mongodb startup file"
      (template "src=mongod.j2 dest=/etc/init.d/mongod-" (jinja "{{ inventory_hostname }}") " mode=0655")
      (delegate_to (jinja "{{ item }}"))
      (with_items "groups.replication_servers"))
    (task "Create the mongodb configuration file"
      (template "src=mongod.conf.j2 dest=/etc/mongod-" (jinja "{{ inventory_hostname }}") ".conf")
      (delegate_to (jinja "{{ item }}"))
      (with_items "groups.replication_servers"))
    (task "Copy the keyfile for authentication"
      (copy "src=secret dest=" (jinja "{{ mongodb_datadir_prefix }}") "/secret owner=mongod group=mongod mode=0400"))
    (task "Start the mongodb service"
      (command "creates=/var/lock/subsys/mongod-" (jinja "{{ inventory_hostname }}") " /etc/init.d/mongod-" (jinja "{{ inventory_hostname }}") " start")
      (delegate_to (jinja "{{ item }}"))
      (with_items "groups.replication_servers"))
    (task "Create the file to initialize the mongod replica set"
      (template "src=repset_init.j2 dest=/tmp/repset_init.js"))
    (task "Pause for a while"
      (pause "seconds=20"))
    (task "Initialize the replication set"
      (shell "/usr/bin/mongo --port \"" (jinja "{{ mongod_port }}") "\" /tmp/repset_init.js"))))
