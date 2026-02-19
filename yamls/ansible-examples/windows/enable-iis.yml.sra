(playbook "ansible-examples/windows/enable-iis.yml"
    (play
    (name "Install IIS")
    (hosts "all")
    (gather_facts "false")
    (tasks
      (task "Install IIS"
        (win_feature 
          (name "Web-Server")
          (state "present")
          (restart "yes")
          (include_sub_features "yes")
          (include_management_tools "yes"))))))
