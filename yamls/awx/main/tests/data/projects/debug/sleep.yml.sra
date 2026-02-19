(playbook "awx/main/tests/data/projects/debug/sleep.yml"
    (play
    (hosts "all")
    (gather_facts "false")
    (connection "local")
    (vars
      (sleep_interval "5"))
    (tasks
      (task "sleep for a specified interval"
        (command "sleep '" (jinja "{{ sleep_interval }}") "'")))))
