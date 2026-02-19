(playbook "ansible-for-devops/elk/provisioning/elk/main.yml"
    (play
    (hosts "logs")
    (gather_facts "yes")
    (vars_files (list
        "vars/main.yml"))
    (pre_tasks
      (task "Update apt cache if needed."
        (apt "update_cache=yes cache_valid_time=86400")))
    (roles
      "geerlingguy.java"
      "geerlingguy.nginx"
      "geerlingguy.pip"
      "geerlingguy.elasticsearch"
      "geerlingguy.elasticsearch-curator"
      "geerlingguy.kibana"
      "geerlingguy.logstash"
      "geerlingguy.filebeat")))
