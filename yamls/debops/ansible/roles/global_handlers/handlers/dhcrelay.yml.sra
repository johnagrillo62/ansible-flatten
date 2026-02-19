(playbook "debops/ansible/roles/global_handlers/handlers/dhcrelay.yml"
  (tasks
    (task "Restart isc-dhcp-relay"
      (ansible.builtin.service 
        (name "isc-dhcp-relay")
        (state "restarted")))))
