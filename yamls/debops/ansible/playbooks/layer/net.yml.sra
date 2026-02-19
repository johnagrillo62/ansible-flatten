(playbook "debops/ansible/playbooks/layer/net.yml"
  (tasks
    (task "Configure network interfaces via networkd"
      (import_playbook "../service/networkd.yml"))
    (task "Configure network interfaces via ifupdown"
      (import_playbook "../service/ifupdown.yml"))
    (task "Configure IPv6 Router Advertisement daemon"
      (import_playbook "../service/radvd.yml"))
    (task "Configure ISC DHCP daemon"
      (import_playbook "../service/dhcpd.yml"))
    (task "Configure NTP service"
      (import_playbook "../service/ntp.yml"))
    (task "Configure unbound service"
      (import_playbook "../service/unbound.yml"))
    (task "Configure DNSmasq service"
      (import_playbook "../service/dnsmasq.yml"))
    (task "Configure Tinc VPN service"
      (import_playbook "../service/tinc.yml"))
    (task "Configure ISC DHCP Relay service"
      (import_playbook "../service/dhcrelay.yml"))
    (task "Configure DHCP Probe service"
      (import_playbook "../service/dhcp_probe.yml"))
    (task "Configure SSL Tunnel service"
      (import_playbook "../service/stunnel.yml"))
    (task "Configure keepalived service"
      (import_playbook "../service/keepalived.yml"))
    (task "Configure Avahi service"
      (import_playbook "../service/avahi.yml"))))
