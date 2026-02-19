(playbook "ansible-tuto/step-12/site.yml"
    (play
    (hosts "web")
    (roles
      "apache"))
    (play
    (hosts "haproxy")
    (roles
      "haproxy")))
