(playbook "ansible-for-devops/lamp-infrastructure/playbooks/www/vars.yml"
  (firewall_allowed_tcp_ports (list
      "22"
      "80")))
