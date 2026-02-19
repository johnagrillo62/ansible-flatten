(playbook "ansible-tuto/step-13/site.yml"
    (play
    (hosts "web")
    (roles
      "apache"))
    (play
    (hosts "haproxy")
    (roles
      "haproxy")))
