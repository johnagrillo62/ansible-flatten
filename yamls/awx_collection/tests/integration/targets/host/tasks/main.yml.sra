(playbook "awx_collection/tests/integration/targets/host/tasks/main.yml"
  (tasks
    (task "Generate a test ID"
      (set_fact 
        (test_id (jinja "{{ lookup('password', '/dev/null chars=ascii_letters length=16') }}")))
      (when "test_id is not defined"))
    (task "Generate names"
      (set_fact 
        (host_name "AWX-Collection-tests-host-host-" (jinja "{{ test_id }}"))
        (inv_name "AWX-Collection-tests-host-inv-" (jinja "{{ test_id }}"))))
    (task "Create an Inventory"
      (inventory 
        (name (jinja "{{ inv_name }}"))
        (organization "Default")
        (state "present"))
      (register "result"))
    (task "Create a Host"
      (host 
        (name (jinja "{{ host_name }}"))
        (inventory (jinja "{{ result.id }}"))
        (state "present")
        (variables 
          (foo "bar")))
      (register "result"))
    (task
      (assert 
        (that (list
            "result is changed"))))
    (task "Create a Host with exists"
      (host 
        (name (jinja "{{ host_name }}"))
        (inventory (jinja "{{ inv_name }}"))
        (state "exists")
        (variables 
          (foo "bar")))
      (register "result"))
    (task
      (assert 
        (that (list
            "result is not changed"))))
    (task "Modify the host as a no-op"
      (host 
        (name (jinja "{{ host_name }}"))
        (inventory (jinja "{{ inv_name }}")))
      (register "result"))
    (task
      (assert 
        (that (list
            "result is not changed"))))
    (task "Delete a Host"
      (host 
        (name (jinja "{{ host_name }}"))
        (inventory (jinja "{{ inv_name }}"))
        (state "absent")
        (variables 
          (foo "bar")))
      (register "result"))
    (task
      (assert 
        (that (list
            "result is changed"))))
    (task "Create a Host with exists"
      (host 
        (name (jinja "{{ host_name }}"))
        (inventory (jinja "{{ inv_name }}"))
        (state "exists")
        (variables 
          (foo "bar")))
      (register "result"))
    (task
      (assert 
        (that (list
            "result is changed"))))
    (task "Use lookup to check that host was enabled"
      (set_fact 
        (host_enabled_test (jinja "{{ lookup('awx.awx.controller_api', 'hosts/' + result.id | string + '/').enabled }}"))))
    (task "Newly created host should have API default value for enabled"
      (assert 
        (that (list
            "host_enabled_test is true"))))
    (task "Delete a Host"
      (host 
        (name (jinja "{{ result.id }}"))
        (inventory (jinja "{{ inv_name }}"))
        (state "absent"))
      (register "result"))
    (task
      (assert 
        (that (list
            "result is changed"))))
    (task "Check module fails with correct msg"
      (host 
        (name "test-host")
        (description "Host Description")
        (inventory "test-non-existing-inventory")
        (state "present"))
      (register "result")
      (ignore_errors "yes"))
    (task
      (assert 
        (that (list
            "result is failed"
            "'test-non-existing-inventory' in result.msg"
            "result.total_results == 0"))))))
