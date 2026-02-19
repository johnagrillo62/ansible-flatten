(playbook "ansible-examples/mongodb/roles/mongoc/tasks/main.yml"
  (tasks
    (task "Create data directory for mongoc configuration server"
      (file "path=" (jinja "{{ mongodb_datadir_prefix }}") "/configdb state=directory owner=mongod group=mongod"))
    (task "Create the mongo configuration server startup file"
      (template "src=mongoc.j2 dest=/etc/init.d/mongoc mode=0655"))
    (task "Create the mongo configuration server file"
      (template "src=mongoc.conf.j2 dest=/etc/mongoc.conf"))
    (task "Copy the keyfile for authentication"
      (copy "src=roles/mongod/files/secret dest=" (jinja "{{ mongodb_datadir_prefix }}") "/secret owner=mongod group=mongod mode=0400"))
    (task "Start the mongo configuration server service"
      (command "creates=/var/lock/subsys/mongoc /etc/init.d/mongoc start"))
    (task "pause"
      (pause "seconds=20"))
    (task "add the admin user"
      (mongodb_user "database=admin name=admin password=" (jinja "{{ mongo_admin_pass }}") " login_port=" (jinja "{{ mongoc_port }}") " state=present")
      (ignore_errors "yes"))))
