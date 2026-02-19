(playbook "awx_collection/tests/integration/targets/execution_environment/tasks/main.yml"
  (tasks
    (task "Generate a random string for test"
      (set_fact 
        (test_id (jinja "{{ lookup('password', '/dev/null chars=ascii_letters length=16') }}")))
      (when "test_id is not defined"))
    (task "Generate names"
      (set_fact 
        (ee_name "AWX-Collection-tests-ee-" (jinja "{{ test_id }}"))))
    (task
      (block (list
          
          (name "Add an EE")
          (execution_environment 
            (name (jinja "{{ ee_name }}"))
            (description "EE for Testing")
            (image "quay.io/ansible/awx-ee")
            (pull "always")
            (organization "Default"))
          (register "result")
          
          (assert 
            (that (list
                "result is changed")))
          
          (name "Add an EE with exists")
          (execution_environment 
            (name (jinja "{{ ee_name }}"))
            (description "EE for Testing")
            (image "quay.io/ansible/awx-ee")
            (pull "always")
            (organization "Default")
            (state "exists"))
          (register "result")
          
          (assert 
            (that (list
                "result is not changed")))
          
          (name "Delete an EE")
          (execution_environment 
            (name (jinja "{{ ee_name }}"))
            (description "EE for Testing")
            (image "quay.io/ansible/awx-ee")
            (pull "always")
            (organization "Default")
            (state "absent"))
          (register "result")
          
          (assert 
            (that (list
                "result is changed")))
          
          (name "Add an EE with exists")
          (execution_environment 
            (name (jinja "{{ ee_name }}"))
            (description "EE for Testing")
            (image "quay.io/ansible/awx-ee")
            (pull "always")
            (organization "Default")
            (state "exists"))
          (register "result")
          
          (assert 
            (that (list
                "result is changed")))
          
          (name "Associate the Test EE with Default Org (this should fail)")
          (execution_environment 
            (name (jinja "{{ ee_name }}"))
            (organization "Some Org")
            (image "quay.io/ansible/awx-ee"))
          (register "result")
          (ignore_errors "yes")
          
          (assert 
            (that (list
                "result is failed")))
          
          (name "Rename the Test EEs")
          (execution_environment 
            (name (jinja "{{ ee_name }}"))
            (new_name (jinja "{{ ee_name }}") "a")
            (image "quay.io/ansible/awx-ee"))
          (register "result")
          
          (assert 
            (that (list
                "result is changed")))))
      (always (list
          
          (name "Delete the Test EEs")
          (execution_environment 
            (name (jinja "{{ item }}"))
            (state "absent")
            (image "quay.io/ansible/awx-ee"))
          (register "result")
          (loop (list
              (jinja "{{ ee_name }}")
              (jinja "{{ ee_name }}") "a"))
          
          (assert 
            (that (list
                "result is changed"))))))))
