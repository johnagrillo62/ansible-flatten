(playbook "ansible-for-devops/jenkins/provision.yml"
    (play
    (hosts "all")
    (vars
      (ansible_install_method "pip")
      (firewall_allowed_tcp_ports (list
          "22"
          "8080"))
      (jenkins_plugins (list
          "ansicolor")))
    (pre_tasks
      (task "Update apt cache if needed."
        (apt 
          (update_cache "true")
          (cache_valid_time "3600"))))
    (roles
      "geerlingguy.firewall"
      "geerlingguy.pip"
      "geerlingguy.ansible"
      "geerlingguy.java"
      "geerlingguy.jenkins")))
