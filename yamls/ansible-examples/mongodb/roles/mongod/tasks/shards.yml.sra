(playbook "ansible-examples/mongodb/roles/mongod/tasks/shards.yml"
  (tasks
    (task "Create the file to initialize the mongod Shard"
      (template "src=shard_init.j2 dest=/tmp/shard_init_" (jinja "{{ inventory_hostname }}") ".js")
      (delegate_to (jinja "{{ item }}"))
      (with_items "groups.mongos_servers"))
    (task "Add the shard to the mongos"
      (shell "/usr/bin/mongo localhost:" (jinja "{{ mongos_port }}") "/admin -u admin -p " (jinja "{{ mongo_admin_pass }}") " /tmp/shard_init_" (jinja "{{ inventory_hostname }}") ".js")
      (delegate_to (jinja "{{ item }}"))
      (with_items "groups.mongos_servers"))))
