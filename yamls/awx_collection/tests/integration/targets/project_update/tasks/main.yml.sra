(playbook "awx_collection/tests/integration/targets/project_update/tasks/main.yml"
  (tasks
    (task "Generate a random string for test"
      (set_fact 
        (test_id (jinja "{{ lookup('password', '/dev/null chars=ascii_letters length=16') }}")))
      (when "test_id is not defined"))
    (task "Generate names"
      (set_fact 
        (project_name1 "AWX-Collection-tests-project_update-project-" (jinja "{{ test_id }}"))))
    (task "Create a git project without credentials without waiting"
      (project 
        (name (jinja "{{ project_name1 }}"))
        (organization "Default")
        (scm_type "git")
        (scm_url "https://github.com/ansible/ansible-tower-samples")
        (wait "false"))
      (register "project_create_result"))
    (task
      (assert 
        (that (list
            "project_create_result is changed"))))
    (task "Update a project without waiting"
      (project_update 
        (name (jinja "{{ project_name1 }}"))
        (organization "Default")
        (wait "false"))
      (register "result"))
    (task
      (assert 
        (that (list
            "result is changed"))))
    (task "Update a project and wait"
      (project_update 
        (name (jinja "{{ project_name1 }}"))
        (organization "Default")
        (wait "true"))
      (register "result"))
    (task
      (assert 
        (that (list
            "result is successful"))))
    (task "Update a project by ID"
      (project_update 
        (name (jinja "{{ project_create_result.id }}"))
        (organization "Default")
        (wait "true"))
      (register "result"))
    (task
      (assert 
        (that (list
            "result is successful"
            "result is not changed"))))
    (task "Delete the test project 1"
      (project 
        (name (jinja "{{ project_name1 }}"))
        (organization "Default")
        (state "absent"))
      (register "result")
      (until "result is changed")
      (retries "6")
      (delay "5"))
    (task
      (assert 
        (that (list
            "result is changed"))))))
