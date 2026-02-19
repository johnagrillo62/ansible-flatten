(playbook "awx_collection/tests/integration/targets/group/tasks/main.yml"
  (tasks
    (task "Generate a test ID"
      (set_fact 
        (test_id (jinja "{{ lookup('password', '/dev/null chars=ascii_letters length=16') }}")))
      (when "test_id is not defined"))
    (task "Generate names"
      (set_fact 
        (group_name1 "AWX-Collection-tests-group-group1-" (jinja "{{ test_id }}"))
        (group_name2 "AWX-Collection-tests-group-group2-" (jinja "{{ test_id }}"))
        (group_name3 "AWX-Collection-tests-group-group3-" (jinja "{{ test_id }}"))
        (group_name4 "AWX-Collection-tests-group-group4-" (jinja "{{ test_id }}"))
        (inv_name "AWX-Collection-tests-group-inv-" (jinja "{{ test_id }}"))
        (host_name1 "AWX-Collection-tests-group-host1-" (jinja "{{ test_id }}"))
        (host_name2 "AWX-Collection-tests-group-host2-" (jinja "{{ test_id }}"))
        (host_name3 "AWX-Collection-tests-group-host3-" (jinja "{{ test_id }}"))
        (host_name4 "AWX-Collection-tests-group-host4-" (jinja "{{ test_id }}"))))
    (task "Create an Inventory"
      (inventory 
        (name (jinja "{{ inv_name }}"))
        (organization "Default")
        (state "present"))
      (register "inv_result"))
    (task "Create a Host"
      (host 
        (name (jinja "{{ host_name4 }}"))
        (inventory (jinja "{{ inv_name }}"))
        (state "present"))
      (register "host_result"))
    (task "Add Host to Group"
      (group 
        (name (jinja "{{ group_name1 }}"))
        (inventory (jinja "{{ inv_name }}"))
        (hosts (list
            (jinja "{{ host_name4 }}")))
        (preserve_existing_hosts "true"))
      (register "group_result"))
    (task
      (assert 
        (that (list
            "inv_result is changed"
            "host_result is changed"
            "group_result is changed"))))
    (task "Create Group 1"
      (group 
        (name (jinja "{{ group_name1 }}"))
        (inventory (jinja "{{ inv_result.id }}"))
        (state "present")
        (variables 
          (foo "bar")))
      (register "result"))
    (task
      (assert 
        (that (list
            "result is changed"))))
    (task "Create Group 1 with exists"
      (group 
        (name (jinja "{{ group_name1 }}"))
        (inventory (jinja "{{ inv_name }}"))
        (state "exists")
        (variables 
          (foo "bar")))
      (register "result"))
    (task
      (assert 
        (that (list
            "result is not changed"))))
    (task "Delete Group 1"
      (group 
        (name (jinja "{{ group_name1 }}"))
        (inventory (jinja "{{ inv_name }}"))
        (state "absent")
        (variables 
          (foo "bar")))
      (register "result"))
    (task
      (assert 
        (that (list
            "result is changed"))))
    (task "Create Group 1 with exists"
      (group 
        (name (jinja "{{ group_name1 }}"))
        (inventory (jinja "{{ inv_name }}"))
        (state "exists")
        (variables 
          (foo "bar")))
      (register "result"))
    (task
      (assert 
        (that (list
            "result is changed"))))
    (task "Create Group 2"
      (group 
        (name (jinja "{{ group_name2 }}"))
        (inventory (jinja "{{ inv_name }}"))
        (state "present")
        (variables 
          (foo "bar")))
      (register "result"))
    (task
      (assert 
        (that (list
            "result is changed"))))
    (task "Create Group 3"
      (group 
        (name (jinja "{{ group_name3 }}"))
        (inventory (jinja "{{ inv_name }}"))
        (state "present")
        (variables 
          (foo "bar")))
      (register "result"))
    (task
      (assert 
        (that (list
            "result is changed"))))
    (task "add hosts"
      (host 
        (name (jinja "{{ item }}"))
        (inventory (jinja "{{ inv_name }}")))
      (loop (list
          (jinja "{{ host_name1 }}")
          (jinja "{{ host_name2 }}")
          (jinja "{{ host_name3 }}"))))
    (task "Create Group 1 with hosts and sub group of Group 2"
      (group 
        (name (jinja "{{ group_name1 }}"))
        (inventory (jinja "{{ inv_name }}"))
        (hosts (list
            (jinja "{{ host_name1 }}")
            (jinja "{{ host_name2 }}")))
        (children (list
            (jinja "{{ group_name2 }}")))
        (state "present")
        (variables 
          (foo "bar")))
      (register "result"))
    (task "Create Group 1 with hosts and sub group"
      (group 
        (name (jinja "{{ group_name1 }}"))
        (inventory (jinja "{{ inv_name }}"))
        (hosts (list
            (jinja "{{ host_name3 }}")))
        (children (list
            (jinja "{{ group_name3 }}")))
        (state "present")
        (preserve_existing_hosts "true")
        (preserve_existing_children "true"))
      (register "result"))
    (task "Find number of hosts in " (jinja "{{ group_name1 }}")
      (set_fact 
        (group1_host_count (jinja "{{ lookup('awx.awx.controller_api', 'groups/' + result.id | string + '/all_hosts/') | length }}"))))
    (task
      (assert 
        (that (list
            "group1_host_count == 3"))))
    (task "Delete Group 3"
      (group 
        (name (jinja "{{ group_name3 }}"))
        (inventory (jinja "{{ inv_name }}"))
        (state "absent"))
      (register "result"))
    (task
      (assert 
        (that (list
            "result is changed"))))
    (task "Delete Group 1"
      (group 
        (name (jinja "{{ group_name1 }}"))
        (inventory (jinja "{{ inv_name }}"))
        (state "absent"))
      (register "result"))
    (task
      (assert 
        (that (list
            "result is changed"))))
    (task "Delete Group 2"
      (group 
        (name (jinja "{{ group_name2 }}"))
        (inventory (jinja "{{ inv_name }}"))
        (state "absent"))
      (register "result"))
    (task
      (assert 
        (that (list
            "result is not changed"))))
    (task "Check module fails with correct msg"
      (group 
        (name "test-group")
        (description "Group Description")
        (inventory "test-non-existing-inventory")
        (state "present"))
      (register "result")
      (ignore_errors "yes"))
    (task
      (assert 
        (that (list
            "result is failed"
            "result is not changed"
            "'test-non-existing-inventory' in result.msg"
            "result.total_results == 0"))))
    (task "add hosts"
      (host 
        (name (jinja "{{ item }}"))
        (inventory (jinja "{{ inv_name }}")))
      (loop (list
          (jinja "{{ host_name1 }}")
          (jinja "{{ host_name2 }}")
          (jinja "{{ host_name3 }}"))))
    (task "add mid level group"
      (group 
        (name (jinja "{{ group_name2 }}"))
        (inventory (jinja "{{ inv_name }}"))
        (hosts (list
            (jinja "{{ host_name3 }}")))))
    (task "add top group"
      (group 
        (name (jinja "{{ group_name3 }}"))
        (inventory (jinja "{{ inv_name }}"))
        (hosts (list
            (jinja "{{ host_name1 }}")
            (jinja "{{ host_name2 }}")))
        (children (list
            (jinja "{{ group_name2 }}")))))
    (task "Delete the parent group"
      (group 
        (name (jinja "{{ group_name3 }}"))
        (inventory (jinja "{{ inv_name }}"))
        (state "absent")))
    (task "Delete the child group"
      (group 
        (name (jinja "{{ group_name2 }}"))
        (inventory (jinja "{{ inv_name }}"))
        (state "absent")))
    (task "Delete an Inventory"
      (inventory 
        (name (jinja "{{ inv_name }}"))
        (organization "Default")
        (state "absent")))))
