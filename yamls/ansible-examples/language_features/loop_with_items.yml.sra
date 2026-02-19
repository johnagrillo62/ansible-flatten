(playbook "ansible-examples/language_features/loop_with_items.yml"
    (play
    (hosts "all")
    (remote_user "root")
    (tasks
      (task "install packages"
        (yum "name=" (jinja "{{ item }}") " state=installed")
        (with_items (list
            "cobbler"
            "httpd")))
      (task "configure users"
        (user "name=" (jinja "{{ item }}") " state=present groups=wheel")
        (with_items (list
            "testuser1"
            "testuser2")))
      (task "remove users"
        (user "name=" (jinja "{{ item }}") " state=absent")
        (with_items (list
            "testuser1"
            "testuser2")))
      (task "copy templates"
        (template "src=" (jinja "{{ item.src }}") " dest=" (jinja "{{ item.dest }}"))
        (with_items (list
            
            (src "templates/testsource1")
            (dest "/example/dest1/test.conf")
            
            (src "templates/testsource2")
            (dest "/example/dest2/test.conf")))))))
