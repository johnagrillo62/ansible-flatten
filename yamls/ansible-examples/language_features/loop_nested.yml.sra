(playbook "ansible-examples/language_features/loop_nested.yml"
    (play
    (hosts "all")
    (tasks
      (task
        (shell "echo \"nested test a=" (jinja "{{ item[0] }}") " b=" (jinja "{{ item[1] }}") " c=" (jinja "{{ item[2] }}") "\"")
        (with_nested (list
            (list
              "red"
              "blue"
              "green")
            (list
              "1"
              "2"
              "3")
            (list
              "up"
              "down"
              "strange"))))))
    (play
    (hosts "all")
    (vars
      (listvar1 (list
          "a"
          "b"
          "c")))
    (tasks
      (task
        (shell "echo \"nested test a=" (jinja "{{ item[0] }}") " b=" (jinja "{{ item[1] }}") "\"")
        (with_nested (list
            "listvar1"
            (list
              "1"
              "2"
              "3")))))))
