(playbook "ansible-for-devops/deployments-balancer/playbooks/provision.yml"
    (play
    (name "Firewall configuration.")
    (hosts "all")
    (become "yes")
    (vars
      (firewall_allowed_tcp_ports (list
          "22"
          "80")))
    (pre_tasks
      (task "Update apt cache if needed."
        (apt "update_cache=yes cache_valid_time=3600")))
    (roles
      "geerlingguy.firewall"))
    (play
    (name "HAProxy Load Balancer setup.")
    (hosts "balancer")
    (become "yes")
    (vars
      (haproxy_backend_servers (list
          
          (name "192.168.56.3")
          (address "192.168.56.3:80")
          
          (name "192.168.56.4")
          (address "192.168.56.4:80"))))
    (roles
      "geerlingguy.haproxy"))
    (play
    (name "Apache webserver setup.")
    (hosts "app")
    (become "yes")
    (roles
      "geerlingguy.apache")))
