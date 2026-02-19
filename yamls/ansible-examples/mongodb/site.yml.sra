(playbook "ansible-examples/mongodb/site.yml"
    (play
    (hosts "all")
    (roles
      
        (role "common")))
    (play
    (hosts "mongo_servers")
    (roles
      
        (role "mongod")))
    (play
    (hosts "mongoc_servers")
    (roles
      
        (role "mongoc")))
    (play
    (hosts "mongos_servers")
    (roles
      
        (role "mongos")))
    (play
    (hosts "mongo_servers")
    (tasks
      
      (include "roles/mongod/tasks/shards.yml"))))
