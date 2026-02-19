(playbook "ansible-examples/language_features/user_commands.yml"
    (play
    (hosts "all")
    (remote_user "root")
    (vars
      (password "$1$SomeSalt$UqddPX3r4kH3UL5jq5/ZI."))
    (tasks
      (task "test basic user account creation"
        (user "name=tset comment=TsetUser group=users shell=/sbin/nologin createhome=no"))
      (task
        (user "name=tset comment=NyetUser"))
      (task
        (user "name=tset password=" (jinja "{{password}}")))
      (task
        (user "name=tset groups=dialout,uucp"))
      (task
        (user "name=tset groups=dialout,wheel"))
      (task
        (user "name=tset groups=uucp append=yes"))
      (task
        (user "name=tset state=absent")))))
