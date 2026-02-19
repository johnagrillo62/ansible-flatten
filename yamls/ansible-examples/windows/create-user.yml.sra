(playbook "ansible-examples/windows/create-user.yml"
    (play
    (name "Add a user")
    (hosts "all")
    (gather_facts "false")
    (tasks
      (task "Add User"
        (win_user 
          (name "ansible")
          (password "@ns1bl3")
          (state "present"))))))
