(playbook "ansible-examples/lamp_simple_rhel7/site.yml"
    (play
    (name "apply common configuration to all nodes")
    (hosts "all")
    (remote_user "root")
    (roles
      "common"))
    (play
    (name "configure and deploy the webservers and application code")
    (hosts "webservers")
    (remote_user "root")
    (roles
      "web"))
    (play
    (name "deploy MySQL and configure the databases")
    (hosts "dbservers")
    (remote_user "root")
    (roles
      "db")))
