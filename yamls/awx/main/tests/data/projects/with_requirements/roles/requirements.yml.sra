(playbook "awx/main/tests/data/projects/with_requirements/roles/requirements.yml"
  (tasks
    (task "role_requirement"
      (src "git+file:///tmp/live_tests/role_requirement"))))
