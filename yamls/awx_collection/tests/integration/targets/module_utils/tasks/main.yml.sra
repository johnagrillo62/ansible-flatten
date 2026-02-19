(playbook "awx_collection/tests/integration/targets/module_utils/tasks/main.yml"
  (tasks
    (task "Generate a random string for test"
      (set_fact 
        (test_id (jinja "{{ lookup('password', '/dev/null chars=ascii_letters length=16') }}")))
      (when "test_id is not defined"))
    (task
      (include_tasks 
        (file "test_named_reference.yml")))))
