(playbook "ansible-examples/language_features/complex_args.yml"
    (play
    (hosts "localhost")
    (gather_facts "no")
    (vars
      (complex 
        (ghostbusters (list
            "egon"
            "ray"
            "peter"
            "winston"))
        (mice (list
            "pinky"
            "brain"
            "larry"))))
    (tasks
      (task "this is the basic way data passing works for any module"
        (action "ping data='Hi Mom'"))
      (task "of course this can also be written like so, which is shorter"
        (ping "data='Hi Mom'"))
      (task "but what if you have a complex module that needs complicated data?"
        (ping 
          (data 
            (moo "cow")
            (asdf (list
                "1"
                "2"
                "3"
                "4")))))
      (task "can we make that cleaner? sure!"
        (ping 
          (data (jinja "{{ complex }}")))))))
