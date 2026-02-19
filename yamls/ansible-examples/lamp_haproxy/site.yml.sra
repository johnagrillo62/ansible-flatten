(playbook "ansible-examples/lamp_haproxy/site.yml"
    (play
    (hosts "all")
    (roles
      "common"))
    (play
    (hosts "dbservers")
    (roles
      "db")
    (tags (list
        "db")))
    (play
    (hosts "webservers")
    (roles
      "base-apache"
      "web")
    (tags (list
        "web")))
    (play
    (hosts "lbservers")
    (roles
      "haproxy")
    (tags (list
        "lb")))
    (play
    (hosts "monitoring")
    (roles
      "base-apache"
      "nagios")
    (tags (list
        "monitoring"))))
