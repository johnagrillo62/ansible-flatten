(playbook "awx_collection/tests/integration/targets/role_definition/tasks/main.yml"
  (tasks
    (task "Create Role Definition"
      (role_definition 
        (name "test_view_jt")
        (permissions (list
            "awx.view_jobtemplate"
            "awx.execute_jobtemplate"))
        (content_type "awx.jobtemplate")
        (description "role definition to launch job")
        (state "present"))
      (register "result"))
    (task "Assert result is changed"
      (ansible.builtin.assert 
        (that (list
            "result.changed"))))
    (task "Delete Role Definition"
      (role_definition 
        (name "test_view_jt")
        (permissions (list
            "awx.view_jobtemplate"
            "awx.execute_jobtemplate"))
        (content_type "awx.jobtemplate")
        (description "role definition to launch job")
        (state "absent"))
      (register "result"))
    (task "Assert result is changed"
      (ansible.builtin.assert 
        (that (list
            "result.changed"))))))
