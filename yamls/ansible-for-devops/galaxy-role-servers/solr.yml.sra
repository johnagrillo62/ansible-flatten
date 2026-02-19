(playbook "ansible-for-devops/galaxy-role-servers/solr.yml"
    (play
    (hosts "all")
    (become "yes")
    (roles
      "geerlingguy.java"
      "geerlingguy.solr")))
