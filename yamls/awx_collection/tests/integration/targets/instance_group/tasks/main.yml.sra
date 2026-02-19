(playbook "awx_collection/tests/integration/targets/instance_group/tasks/main.yml"
  (tasks
    (task "Generate test id"
      (set_fact 
        (test_id (jinja "{{ lookup('password', '/dev/null chars=ascii_letters length=16') }}")))
      (when "test_id is not defined"))
    (task "Generate names"
      (set_fact 
        (group_name1 "AWX-Collection-tests-instance_group-group1-" (jinja "{{ test_id }}"))
        (group_name2 "AWX-Collection-tests-instance_group-group2-" (jinja "{{ test_id }}"))
        (cred_name1 "AWX-Collection-tests-instance_group-cred1-" (jinja "{{ test_id }}"))))
    (task
      (block (list
          
          (name "Create an OpenShift Credential")
          (credential 
            (name (jinja "{{ cred_name1 }}"))
            (organization "Default")
            (credential_type "OpenShift or Kubernetes API Bearer Token")
            (inputs 
              (host "https://openshift.org")
              (bearer_token "asdf1234")
              (verify_ssl "false")))
          (register "cred_result")
          
          (assert 
            (that (list
                "cred_result is changed")))
          
          (name "Create an Instance Group")
          (instance_group 
            (name (jinja "{{ group_name1 }}"))
            (policy_instance_percentage "34")
            (policy_instance_minimum "12")
            (state "present"))
          (register "result")
          
          (assert 
            (that (list
                "result is changed")))
          
          (name "Create an Instance Group with exists")
          (instance_group 
            (name (jinja "{{ group_name1 }}"))
            (policy_instance_percentage "34")
            (policy_instance_minimum "12")
            (state "exists"))
          (register "result")
          
          (assert 
            (that (list
                "result is not changed")))
          
          (name "Delete an Instance Group")
          (instance_group 
            (name (jinja "{{ group_name1 }}"))
            (policy_instance_percentage "34")
            (policy_instance_minimum "12")
            (state "absent"))
          (register "result")
          
          (assert 
            (that (list
                "result is changed")))
          
          (name "Create an Instance Group with exists")
          (instance_group 
            (name (jinja "{{ group_name1 }}"))
            (policy_instance_percentage "34")
            (policy_instance_minimum "12")
            (state "exists"))
          (register "result")
          
          (assert 
            (that (list
                "result is changed")))
          
          (name "Update an Instance Group")
          (instance_group 
            (name (jinja "{{ result.id }}"))
            (policy_instance_percentage "34")
            (policy_instance_minimum "24")
            (state "present"))
          (register "result")
          
          (assert 
            (that (list
                "result is changed")))
          
          (name "Create a container group")
          (instance_group 
            (name (jinja "{{ group_name2 }}"))
            (credential (jinja "{{ cred_result.id }}"))
            (is_container_group "true"))
          (register "result")
          
          (assert 
            (that (list
                "result is changed")))))
      (always (list
          
          (name "Delete the instance groups")
          (instance_group 
            (name (jinja "{{ item }}"))
            (state "absent"))
          (loop (list
              (jinja "{{ group_name1 }}")
              (jinja "{{ group_name2 }}")))
          
          (name "Delete the credential")
          (credential 
            (name (jinja "{{ cred_name1 }}"))
            (organization "Default")
            (credential_type "OpenShift or Kubernetes API Bearer Token")))))))
