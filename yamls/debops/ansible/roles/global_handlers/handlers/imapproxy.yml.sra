(playbook "debops/ansible/roles/global_handlers/handlers/imapproxy.yml"
  (tasks
    (task "Restart imapproxy"
      (ansible.builtin.service 
        (name "imapproxy")
        (state "restarted")))))
