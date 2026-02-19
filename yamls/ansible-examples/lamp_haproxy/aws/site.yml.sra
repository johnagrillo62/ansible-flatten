(playbook "ansible-examples/lamp_haproxy/aws/site.yml"
    (play
    (hosts "all")
    (roles
      "common"))
    (play
    (hosts "tag_ansible_group_dbservers")
    (roles
      "db")
    (tags (list
        "db")))
    (play
    (hosts "tag_ansible_group_webservers")
    (roles
      "base-apache"
      "web")
    (tags (list
        "web")))
    (play
    (hosts "tag_ansible_group_lbservers")
    (roles
      "haproxy")
    (tags (list
        "lb")))
    (play
    (hosts "tag_ansible_group_monitoring")
    (roles
      "base-apache"
      "nagios")
    (tags (list
        "monitoring"))))
