(playbook "debops/ansible/roles/global_handlers/handlers/rstudio_server.yml"
  (tasks
    (task "Verify rstudio-server"
      (ansible.builtin.command "rstudio-server test-config")
      (register "global_handlers__rstudio_server_register_test_config")
      (changed_when "global_handlers__rstudio_server_register_test_config.changed | bool")
      (notify (list
          "Restart rstudio-server")))
    (task "Restart rstudio-server"
      (ansible.builtin.service 
        (name "rstudio-server")
        (state "restarted")))))
