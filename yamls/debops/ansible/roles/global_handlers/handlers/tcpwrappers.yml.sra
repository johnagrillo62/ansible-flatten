(playbook "debops/ansible/roles/global_handlers/handlers/tcpwrappers.yml"
  (tasks
    (task "Assemble hosts.allow.d"
      (ansible.builtin.assemble 
        (src "/etc/hosts.allow.d")
        (dest "/etc/hosts.allow")
        (backup "False")
        (mode "0644"))
      (when "(ansible_local.tcpwrappers.enabled | d()) | bool"))))
