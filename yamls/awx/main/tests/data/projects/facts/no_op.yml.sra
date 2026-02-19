(playbook "awx/main/tests/data/projects/facts/no_op.yml"
    (play
    (hosts "all")
    (gather_facts "false")
    (connection "local")
    (vars
      (msg "hello"))
    (tasks
      (task
        (debug "var=msg")))))
