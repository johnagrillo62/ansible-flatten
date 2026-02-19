(playbook "debops/ansible/roles/global_handlers/handlers/nginx.yml"
  (tasks
    (task "Test nginx and restart"
      (ansible.builtin.command "nginx -t")
      (register "global_handlers__nginx_register_check_restart")
      (changed_when "global_handlers__nginx_register_check_restart.changed | bool")
      (notify (list
          "Restart nginx")))
    (task "Test nginx and reload"
      (ansible.builtin.command "nginx -t")
      (register "global_handlers__nginx_register_check_reload")
      (changed_when "global_handlers__nginx_register_check_reload.changed | bool")
      (notify (list
          "Reload nginx")))
    (task "Restart nginx"
      (ansible.builtin.service 
        (name "nginx")
        (state "restarted")))
    (task "Reload nginx"
      (ansible.builtin.service 
        (name "nginx")
        (state "reloaded")))))
