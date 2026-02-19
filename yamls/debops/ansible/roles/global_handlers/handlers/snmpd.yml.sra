(playbook "debops/ansible/roles/global_handlers/handlers/snmpd.yml"
  (tasks
    (task "Restart snmpd"
      (ansible.builtin.service 
        (name "snmpd")
        (enabled "True")
        (state "restarted")))))
