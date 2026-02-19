(playbook "ansible-for-devops/lamp-infrastructure/playbooks/memcached/vars.yml"
  (firewall_allowed_tcp_ports (list
      "22"))
  (firewall_additional_rules (list
      "iptables -A INPUT -p tcp --dport 11211 -s " (jinja "{{ groups['lamp_www'][0] }}") " -j ACCEPT"
      "iptables -A INPUT -p tcp --dport 11211 -s " (jinja "{{ groups['lamp_www'][1] }}") " -j ACCEPT"))
  (memcached_listen_ip "0.0.0.0"))
