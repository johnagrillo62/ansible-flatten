(playbook "debops/ansible/roles/global_handlers/handlers/dhcp_probe.yml"
  (tasks
    (task "Restart dhcp-probe"
      (ansible.builtin.service 
        (name "dhcp-probe")
        (state "restarted")))))
