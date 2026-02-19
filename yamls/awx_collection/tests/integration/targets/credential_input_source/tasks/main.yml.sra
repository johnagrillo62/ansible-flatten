(playbook "awx_collection/tests/integration/targets/credential_input_source/tasks/main.yml"
  (tasks
    (task "Generate a random string for test"
      (set_fact 
        (test_id (jinja "{{ lookup('password', '/dev/null chars=ascii_letters length=16') }}")))
      (when "test_id is not defined"))
    (task "Generate names"
      (set_fact 
        (src_cred_name "AWX-Collection-tests-credential_input_source-src_cred-" (jinja "{{ test_id }}"))
        (target_cred_name "AWX-Collection-tests-credential_input_source-target_cred-" (jinja "{{ test_id }}"))))
    (task "detect credential types"
      (ansible.builtin.set_fact 
        (credentials (jinja "{{ lookup('awx.awx.controller_api', 'credential_types') }}"))))
    (task "Register Credentials found"
      (set_fact 
        (cyberark_found (jinja "{{ 'CyberArk Central Credential Provider Lookup' in credentials | map(attribute='name') | list }}"))))
    (task "Test credential lookup workflow"
      (block (list
          
          (name "Add credential Lookup")
          (credential 
            (description "Credential for Testing Source")
            (name (jinja "{{ src_cred_name }}"))
            (credential_type "CyberArk Central Credential Provider Lookup")
            (inputs 
              (url "https://cyberark.example.com")
              (app_id "My-App-ID"))
            (organization "Default"))
          (register "src_cred_result")
          
          (assert 
            (that (list
                "src_cred_result is changed")))
          
          (name "Add credential Target")
          (credential 
            (description "Credential for Testing Target")
            (name (jinja "{{ target_cred_name }}"))
            (credential_type "Machine")
            (inputs 
              (username "user"))
            (organization "Default"))
          (register "target_cred_result")
          
          (assert 
            (that (list
                "target_cred_result is changed")))
          
          (name "Add credential Input Source")
          (credential_input_source 
            (input_field_name "password")
            (target_credential (jinja "{{ target_cred_result.id }}"))
            (source_credential (jinja "{{ src_cred_result.id }}"))
            (metadata 
              (object_query "Safe=MY_SAFE;Object=AWX-user")
              (object_query_format "Exact"))
            (state "present"))
          (register "result")
          
          (assert 
            (that (list
                "result is changed")))
          
          (name "Add credential Input Source with exists")
          (credential_input_source 
            (input_field_name "password")
            (target_credential (jinja "{{ target_cred_result.id }}"))
            (source_credential (jinja "{{ src_cred_result.id }}"))
            (metadata 
              (object_query "Safe=MY_SAFE;Object=AWX-user")
              (object_query_format "Exact"))
            (state "exists"))
          (register "result")
          
          (assert 
            (that (list
                "result is not changed")))
          
          (name "Delete credential Input Source")
          (credential_input_source 
            (input_field_name "password")
            (target_credential (jinja "{{ target_cred_result.id }}"))
            (source_credential (jinja "{{ src_cred_result.id }}"))
            (metadata 
              (object_query "Safe=MY_SAFE;Object=AWX-user")
              (object_query_format "Exact"))
            (state "absent"))
          (register "result")
          
          (assert 
            (that (list
                "result is changed")))
          
          (name "Add credential Input Source with exists")
          (credential_input_source 
            (input_field_name "password")
            (target_credential (jinja "{{ target_cred_result.id }}"))
            (source_credential (jinja "{{ src_cred_result.id }}"))
            (metadata 
              (object_query "Safe=MY_SAFE;Object=AWX-user")
              (object_query_format "Exact"))
            (state "exists"))
          (register "result")
          
          (assert 
            (that (list
                "result is changed")))
          
          (name "Add Second credential Lookup")
          (credential 
            (description "Credential for Testing Source Change")
            (name (jinja "{{ src_cred_name }}") "-2")
            (credential_type "CyberArk Central Credential Provider Lookup")
            (inputs 
              (url "https://cyberark-prod.example.com")
              (app_id "My-App-ID"))
            (organization "Default"))
          (register "result")
          
          (name "Change credential Input Source")
          (credential_input_source 
            (input_field_name "password")
            (target_credential (jinja "{{ target_cred_name }}"))
            (source_credential (jinja "{{ src_cred_name }}") "-2")
            (state "present"))
          
          (assert 
            (that (list
                "result is changed")))))
      (when "cyberark_found"))
    (task "Clean up if previous block ran"
      (block (list
          
          (name "Remove a credential source")
          (credential_input_source 
            (input_field_name "password")
            (target_credential (jinja "{{ target_cred_name }}"))
            (state "absent"))
          (register "result")
          
          (assert 
            (that (list
                "result is changed")))
          
          (name "Remove credential Lookup")
          (credential 
            (name (jinja "{{ src_cred_name }}"))
            (organization "Default")
            (credential_type "CyberArk Central Credential Provider Lookup")
            (state "absent"))
          (register "result")
          
          (name "Remove Alt credential Lookup")
          (credential 
            (name (jinja "{{ src_cred_name }}") "-2")
            (organization "Default")
            (credential_type "CyberArk Central Credential Provider Lookup")
            (state "absent"))
          (register "result")
          
          (name "Remove credential")
          (credential 
            (name (jinja "{{ target_cred_name }}"))
            (organization "Default")
            (credential_type "Machine")
            (state "absent"))
          (register "result")))
      (when "cyberark_found"))))
