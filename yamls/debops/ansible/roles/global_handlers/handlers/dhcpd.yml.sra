(playbook "debops/ansible/roles/global_handlers/handlers/dhcpd.yml"
  (tasks
    (task "Restart isc-dhcp-server"
      (ansible.builtin.service 
        (name "isc-dhcp-server")
        (state "restarted")))))
