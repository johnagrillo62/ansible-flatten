(playbook "awx/main/tests/data/projects/facts/gather.yml"
    (play
    (hosts "all")
    (vars
      (extra_value ""))
    (gather_facts "false")
    (connection "local")
    (tasks
      (task "set a custom fact"
        (set_fact 
          (foo "bar" (jinja "{{ extra_value }}"))
          (bar 
            (a 
              (b (list
                  "c"
                  "d"))))
          (cacheable "true"))))))
