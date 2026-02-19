(playbook "awx/main/tests/data/projects/debug/debug.yml"
    (play
    (hosts "all")
    (gather_facts "false")
    (connection "local")
    (tasks
      (task
        (debug "msg='hello'")))))
