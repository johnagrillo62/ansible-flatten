(playbook "ansible-for-devops/lamp-infrastructure/playbooks/varnish/vars.yml"
  (firewall_allowed_tcp_ports (list
      "22"
      "80"))
  (varnish_use_default_vcl "false"))
