(playbook "ansible-examples/language_features/intro_example.yml"
    (play
    (name "example play")
    (hosts "all")
    (remote_user "root")
    (vars
      (http_port "80")
      (max_clients "200"))
    (tasks
      (task "longrunner"
        (command "/bin/sleep 15")
        (async "45")
        (poll "5"))
      (task "write some_random_foo configuration"
        (template "src=templates/foo.j2 dest=/etc/some_random_foo.conf")
        (notify (list
            "restart apache")))
      (task "install httpd"
        (yum "pkg=httpd state=latest"))
      (task "httpd start"
        (service "name=httpd state=running")))
    (handlers
      (task "restart apache"
        (service "name=httpd state=restarted")))))
