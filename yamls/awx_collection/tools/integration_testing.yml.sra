(playbook "awx_collection/tools/integration_testing.yml"
    (play
    (hosts "localhost")
    (gather_facts "false")
    (connection "local")
    (collections (list
        "awx.awx"))
    (vars
      (collection_location (jinja "{{ playbook_dir }}") "/..")
      (loc_tests (jinja "{{ collection_location }}") "/tests/integration/targets/")
      (test "ad_hoc_command,host,role"))
    (tasks
      (task "DEBUG - make sure variables are what we expect"
        (ansible.builtin.debug 
          (msg "Running tests at location:
    " (jinja "{{ loc_tests }}") "
Running tests folders:
    " (jinja "{{ test | trim | split(',') }}") "
")))
      (task "Include test targets"
        (ansible.builtin.include_tasks (jinja "{{ loc_tests }}") (jinja "{{ test_name }}") "/tasks/main.yml")
        (loop (jinja "{{ test | trim | split(',') }}"))
        (loop_control 
          (loop_var "test_name"))))))
