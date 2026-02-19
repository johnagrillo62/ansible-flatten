(playbook "awx_collection/tests/integration/targets/credential_type/tasks/main.yml"
  (tasks
    (task "Generate a test ID"
      (set_fact 
        (test_id (jinja "{{ lookup('password', '/dev/null chars=ascii_letters length=16') }}")))
      (when "test_id is not defined"))
    (task "Generate names"
      (set_fact 
        (cred_type_name "AWX-Collection-tests-credential_type-cred-type-" (jinja "{{ test_id }}"))))
    (task
      (block (list
          
          (name "Add Tower credential type")
          (credential_type 
            (description "Credential type for Test")
            (name (jinja "{{ cred_type_name }}"))
            (kind "cloud")
            (inputs 
              (fields (list
                  
                  (type "string")
                  (id "username")
                  (label "Username")
                  
                  (secret "true")
                  (type "string")
                  (id "password")
                  (label "Password")))
              (required (list
                  "username"
                  "password")))
            (injectors 
              (extra_vars 
                (test "foo"))))
          (register "result")
          
          (assert 
            (that (list
                "result is changed")))
          
          (name "Add Tower credential type with exists")
          (credential_type 
            (description "Credential type for Test")
            (name (jinja "{{ cred_type_name }}"))
            (kind "cloud")
            (inputs 
              (fields (list
                  
                  (type "string")
                  (id "username")
                  (label "Username")
                  
                  (secret "true")
                  (type "string")
                  (id "password")
                  (label "Password")))
              (required (list
                  "username"
                  "password")))
            (injectors 
              (extra_vars 
                (test "foo")))
            (state "exists"))
          (register "result")
          
          (assert 
            (that (list
                "result is not changed")))
          
          (name "Delete the credential type")
          (credential_type 
            (description "Credential type for Test")
            (name (jinja "{{ cred_type_name }}"))
            (kind "cloud")
            (inputs 
              (fields (list
                  
                  (type "string")
                  (id "username")
                  (label "Username")
                  
                  (secret "true")
                  (type "string")
                  (id "password")
                  (label "Password")))
              (required (list
                  "username"
                  "password")))
            (injectors 
              (extra_vars 
                (test "foo")))
            (state "absent"))
          (register "result")
          
          (assert 
            (that (list
                "result is changed")))
          
          (name "Add Tower credential type with exists")
          (credential_type 
            (description "Credential type for Test")
            (name (jinja "{{ cred_type_name }}"))
            (kind "cloud")
            (inputs 
              (fields (list
                  
                  (type "string")
                  (id "username")
                  (label "Username")
                  
                  (secret "true")
                  (type "string")
                  (id "password")
                  (label "Password")))
              (required (list
                  "username"
                  "password")))
            (injectors 
              (extra_vars 
                (test "foo")))
            (state "exists"))
          (register "result")
          
          (assert 
            (that (list
                "result is changed")))
          
          (name "Rename Tower credential type")
          (credential_type 
            (name (jinja "{{ cred_type_name }}"))
            (new_name (jinja "{{ cred_type_name }}") "a")
            (kind "cloud"))
          (register "result")
          
          (assert 
            (that (list
                "result is changed")))))
      (always (list
          
          (name "Remove a Tower credential type")
          (credential_type 
            (name (jinja "{{ item }}"))
            (state "absent"))
          (register "result")
          (loop (list
              (jinja "{{ cred_type_name }}")
              (jinja "{{ cred_type_name }}") "a"))
          
          (assert 
            (that (list
                "result is changed"))))))))
