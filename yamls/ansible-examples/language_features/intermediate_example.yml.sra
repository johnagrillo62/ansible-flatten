(playbook "ansible-examples/language_features/intermediate_example.yml"
    (play
    (hosts "all")
    (vars
      (release "2.0"))
    (vars_files (list
        "vars/external_vars.yml"))
    (tasks
      (task "arbitrary command"
        (command "/bin/true"))
      
      (include "tasks/base.yml"))
    (handlers
      
      (include "handlers/handlers.yml")
      (task "restart foo"
        (service "name=foo state=restarted"))))
    (play
    (hosts "webservers")
    (remote_user "mdehaan")
    (vars
      (release "2.0"))
    (vars_files (list
        "vars/external_vars.yml"))
    (tasks
      (task "some random command"
        (command "/bin/true")))))
