(playbook "awx_collection/tests/integration/targets/role_user_assignment/tasks/main.yml"
  (tasks
    (task "Create user"
      (awx.awx.user 
        (username "testing_user")
        (password (jinja "{{ 65535 | random | to_uuid }}"))))
    (task "Create Job Template"
      (job_template 
        (name "Demo Job Template")
        (job_type "run")
        (inventory "Demo Inventory")
        (project "Demo Project")
        (playbook "hello_world.yml"))
      (register "job_template"))
    (task "Create Role Definition"
      (role_definition 
        (name "test_view_jt")
        (permissions (list
            "awx.view_jobtemplate"
            "awx.execute_jobtemplate"))
        (content_type "awx.jobtemplate")
        (description "role definition to launch job")))
    (task "Create Role User Assignment"
      (role_user_assignment 
        (role_definition "test_view_jt")
        (user "testing_user")
        (object_id (jinja "{{ job_template.id }}")))
      (register "result"))
    (task "Assert result is changed"
      (ansible.builtin.assert 
        (that (list
            "result.changed"))))
    (task "Delete Role User Assigment"
      (role_user_assignment 
        (role_definition "test_view_jt")
        (user "testing_user")
        (object_id (jinja "{{ job_template.id }}"))
        (state "absent"))
      (register "result"))
    (task "Assert result is changed"
      (ansible.builtin.assert 
        (that (list
            "result.changed"))))
    (task "Create Role Definition"
      (role_definition 
        (name "test_view_jt")
        (permissions (list
            "awx.view_jobtemplate"
            "awx.execute_jobtemplate"))
        (content_type "awx.jobtemplate")
        (description "role definition to launch job")
        (state "absent")))
    (task "Delete user"
      (ansible.builtin.user 
        (name "testing_user")
        (state "absent")))))
