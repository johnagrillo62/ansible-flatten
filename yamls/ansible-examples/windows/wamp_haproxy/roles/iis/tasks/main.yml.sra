(playbook "ansible-examples/windows/wamp_haproxy/roles/iis/tasks/main.yml"
  (tasks
    (task "Install IIS"
      (win_feature 
        (name "Web-Server")
        (state "present")
        (restart "yes")
        (include_sub_features "yes")
        (include_management_tools "yes")))))
