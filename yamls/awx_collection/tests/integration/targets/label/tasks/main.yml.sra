(playbook "awx_collection/tests/integration/targets/label/tasks/main.yml"
  (tasks
    (task "Generate a test ID"
      (set_fact 
        (test_id (jinja "{{ lookup('password', '/dev/null chars=ascii_letters length=16') }}")))
      (when "test_id is not defined"))
    (task "Generate names"
      (set_fact 
        (label_name "AWX-Collection-tests-label-label-" (jinja "{{ test_id }}"))))
    (task "Create a Label"
      (label 
        (name (jinja "{{ label_name }}"))
        (organization "Default")
        (state "present"))
      (register "results"))
    (task
      (assert 
        (that (list
            "results is changed"))))
    (task "Create a Label with exists"
      (label 
        (name (jinja "{{ label_name }}"))
        (organization "Default")
        (state "exists"))
      (register "results"))
    (task
      (assert 
        (that (list
            "results is not changed"))))
    (task "Check module fails with correct msg"
      (label 
        (name "Test Label")
        (organization "Non_existing_org")
        (state "present"))
      (register "result")
      (ignore_errors "yes"))
    (task
      (assert 
        (that (list
            "result is failed"
            "result is not changed"
            "'Non_existing_org' in result.msg"
            "result.total_results == 0"))))))
