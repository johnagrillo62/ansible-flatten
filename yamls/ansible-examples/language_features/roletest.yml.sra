(playbook "ansible-examples/language_features/roletest.yml"
    (play
    (hosts "all")
    (pre_tasks
      (task
        (local_action "shell echo \"hi this is a pre_task step about " (jinja "{{ inventory_hostname }}") "\"")))
    (roles
      
        (role "foo")
        (param1 "1000")
        (param2 "2000")
        (tags (list
            "foo"
            "bar"))
      
        (role "foo")
        (param1 "8000")
        (param2 "9000")
        (tags (list
            "baz")))
    (tasks
      (task
        (shell "echo 'this is a loose task'")))
    (post_tasks
      (task
        (local_action "shell echo 'this is a post_task about " (jinja "{{ inventory_hostname }}") "'")))))
