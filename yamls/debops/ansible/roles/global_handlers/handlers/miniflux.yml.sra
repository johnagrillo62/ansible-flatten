(playbook "debops/ansible/roles/global_handlers/handlers/miniflux.yml"
  (tasks
    (task "Restart miniflux"
      (ansible.builtin.service 
        (name "miniflux")
        (state "restarted")))))
