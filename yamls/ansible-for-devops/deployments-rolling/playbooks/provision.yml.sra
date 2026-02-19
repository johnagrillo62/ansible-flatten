(playbook "ansible-for-devops/deployments-rolling/playbooks/provision.yml"
    (play
    (hosts "nodejs-api")
    (become "yes")
    (vars
      (nodejs_install_npm_user "root")
      (npm_config_prefix "/usr")
      (nodejs_npm_global_packages (list
          "forever"))
      (firewall_allowed_tcp_ports (list
          "22"
          "8080")))
    (pre_tasks
      (task "Update apt cache if needed."
        (apt "update_cache=yes cache_valid_time=3600")))
    (roles
      "geerlingguy.firewall"
      "geerlingguy.nodejs"
      "geerlingguy.git")))
