(playbook "debops/ansible/roles/global_handlers/handlers/kibana.yml"
  (tasks
    (task "Start kibana"
      (ansible.builtin.service 
        (name "kibana")
        (state "started")
        (enabled "True")))
    (task "Restart kibana"
      (ansible.builtin.service 
        (name "kibana")
        (state "restarted")))))
