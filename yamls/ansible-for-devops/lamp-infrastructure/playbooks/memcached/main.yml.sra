(playbook "ansible-for-devops/lamp-infrastructure/playbooks/memcached/main.yml"
    (play
    (hosts "lamp_memcached")
    (become "yes")
    (vars_files (list
        "vars.yml"))
    (roles
      "geerlingguy.firewall"
      "geerlingguy.memcached")))
