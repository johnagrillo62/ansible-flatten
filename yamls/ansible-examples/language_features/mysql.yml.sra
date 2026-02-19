(playbook "ansible-examples/language_features/mysql.yml"
    (play
    (hosts "all")
    (remote_user "root")
    (tasks
      (task "Create database user"
        (mysql_user "user=bob password=12345 priv=*.*:ALL state=present"))
      (task "Create database"
        (mysql_db "db=bobdata state=present"))
      (task "Ensure no user named 'sally' exists and delete if found."
        (mysql_user "user=sally state=absent")))))
