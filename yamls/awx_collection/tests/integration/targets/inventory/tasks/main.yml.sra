(playbook "awx_collection/tests/integration/targets/inventory/tasks/main.yml"
  (tasks
    (task "Generate a test ID"
      (set_fact 
        (test_id (jinja "{{ lookup('password', '/dev/null chars=ascii_letters length=16') }}")))
      (when "test_id is not defined"))
    (task "Generate names"
      (set_fact 
        (inv_name1 "AWX-Collection-tests-inventory-inv1-" (jinja "{{ test_id }}"))
        (inv_name2 "AWX-Collection-tests-inventory-inv2-" (jinja "{{ test_id }}"))
        (group_name1 "AWX-Collection-tests-instance_group-group1-" (jinja "{{ test_id }}"))))
    (task
      (block (list
          
          (name "Create an Instance Group")
          (instance_group 
            (name (jinja "{{ group_name1 }}"))
            (state "present"))
          (register "result")
          
          (assert 
            (that (list
                "result is changed")))
          
          (name "Create an Inventory")
          (inventory 
            (name (jinja "{{ inv_name1 }}"))
            (organization "Default")
            (instance_groups (list
                (jinja "{{ group_name1 }}")))
            (state "present"))
          (register "result")
          
          (assert 
            (that (list
                "result is changed")))
          
          (name "Create an Inventory with exists")
          (inventory 
            (name (jinja "{{ inv_name1 }}"))
            (organization "Default")
            (instance_groups (list
                (jinja "{{ group_name1 }}")))
            (state "exists"))
          (register "result")
          
          (assert 
            (that (list
                "result is not changed")))
          
          (name "Delete an Inventory")
          (inventory 
            (name (jinja "{{ inv_name1 }}"))
            (organization "Default")
            (instance_groups (list
                (jinja "{{ group_name1 }}")))
            (state "absent"))
          (register "result")
          
          (assert 
            (that (list
                "result is changed")))
          
          (name "Create an Inventory with exists")
          (inventory 
            (name (jinja "{{ inv_name1 }}"))
            (organization "Default")
            (instance_groups (list
                (jinja "{{ group_name1 }}")))
            (state "exists"))
          (register "result")
          
          (assert 
            (that (list
                "result is changed")))
          
          (name "Test Inventory module idempotency")
          (inventory 
            (name (jinja "{{ result.id }}"))
            (organization "Default")
            (state "present"))
          (register "result")
          
          (assert 
            (that (list
                "result is not changed")))
          
          (name "Copy an inventory")
          (inventory 
            (name "copy_" (jinja "{{ inv_name1 }}"))
            (copy_from (jinja "{{ inv_name1 }}"))
            (organization "Default")
            (description "Our Foo Cloud Servers")
            (state "present"))
          (register "result")
          
          (assert 
            (that (list
                "result.copied")))
          
          (name "Rename an inventory")
          (inventory 
            (name "copy_" (jinja "{{ inv_name1 }}"))
            (new_name "copy_" (jinja "{{ inv_name1 }}") "a")
            (organization "Default")
            (state "present"))
          (register "result")
          
          (assert 
            (that (list
                "result.changed")))
          
          (name "Delete an Inventory")
          (inventory 
            (name "copy_" (jinja "{{ inv_name1 }}") "a")
            (organization "Default")
            (state "absent"))
          (register "result")
          
          (assert 
            (that (list
                "result is changed")))
          
          (name "Fail Change Regular to Smart")
          (inventory 
            (name (jinja "{{ inv_name1 }}"))
            (organization "Default")
            (kind "smart"))
          (register "result")
          (ignore_errors "yes")
          
          (assert 
            (that (list
                "result is failed")))
          
          (name "Create a smart inventory")
          (inventory 
            (name (jinja "{{ inv_name2 }}"))
            (organization "Default")
            (kind "smart")
            (host_filter "name=foo"))
          (register "result")
          
          (assert 
            (that (list
                "result is changed")))
          
          (name "Delete a smart inventory")
          (inventory 
            (name (jinja "{{ inv_name2 }}"))
            (organization "Default")
            (kind "smart")
            (host_filter "name=foo")
            (state "absent"))
          (register "result")
          
          (assert 
            (that (list
                "result is changed")))
          
          (name "Delete an Inventory")
          (inventory 
            (name (jinja "{{ inv_name1 }}"))
            (organization "Default")
            (state "absent"))
          (register "result")
          
          (assert 
            (that (list
                "result is changed")))
          
          (name "Delete a Non-Existent Inventory")
          (inventory 
            (name (jinja "{{ inv_name1 }}"))
            (organization "Default")
            (state "absent"))
          (register "result")
          
          (assert 
            (that (list
                "result is not changed")))
          
          (name "Check module fails with correct msg")
          (inventory 
            (name "test-inventory")
            (description "Inventory Description")
            (organization "test-non-existing-org")
            (state "present"))
          (register "result")
          (ignore_errors "yes")
          
          (assert 
            (that (list
                "result is failed"
                "result is not changed"
                "'test-non-existing-org' in result.msg and 'returned 0 items, expected 1' in result.msg"
                "result.total_results == 0")))))
      (always (list
          
          (name "Delete Inventories")
          (inventory 
            (name (jinja "{{ item }}"))
            (organization "Default")
            (state "absent"))
          (loop (list
              (jinja "{{ inv_name1 }}")
              (jinja "{{ inv_name2 }}")
              "copy_" (jinja "{{ inv_name1 }}")))
          
          (name "Delete the instance groups")
          (instance_group 
            (name (jinja "{{ group_name1 }}"))
            (state "absent")))))))
