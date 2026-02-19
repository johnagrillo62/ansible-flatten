(playbook "awx/main/tests/data/projects/with_requirements/use_requirement.yml"
    (play
    (hosts "all")
    (connection "local")
    (gather_facts "false")
    (tasks
      (task
        (include_role 
          (name "role_requirement"))))))
