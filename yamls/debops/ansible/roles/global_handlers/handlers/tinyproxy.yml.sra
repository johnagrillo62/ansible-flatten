(playbook "debops/ansible/roles/global_handlers/handlers/tinyproxy.yml"
  (tasks
    (task "Restart tinyproxy"
      (ansible.builtin.service 
        (name "tinyproxy")
        (state "restarted")
        (enabled "yes")))))
