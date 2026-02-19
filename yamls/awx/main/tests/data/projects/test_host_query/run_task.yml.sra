(playbook "awx/main/tests/data/projects/test_host_query/run_task.yml"
    (play
    (hosts "all")
    (gather_facts "false")
    (connection "local")
    (tasks
      
      (demo.query.example null)
      (register "result")
      (task
        (debug "var=result")))))
