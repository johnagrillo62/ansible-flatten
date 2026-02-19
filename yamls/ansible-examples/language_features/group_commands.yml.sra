(playbook "ansible-examples/language_features/group_commands.yml"
    (play
    (hosts "all")
    (remote_user "root")
    (become "yes")
    (become_method "sudo")
    (tasks
      (task "create a group"
        (group "name=tset"))
      (task
        (group "name=tset gid=7777"))
      (task
        (group "name=tset state=absent")))))
