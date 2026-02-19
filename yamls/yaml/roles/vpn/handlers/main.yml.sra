(playbook "yaml/roles/vpn/handlers/main.yml"
  (tasks
    (task "restart dnsmasq"
      (service "name=dnsmasq state=restarted"))
    (task "restart openvpn"
      (service "name=openvpn@server state=restarted"))))
