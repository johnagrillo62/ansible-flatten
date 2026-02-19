(playbook "awx_collection/tests/integration/targets/organization/tasks/main.yml"
  (tasks
    (task "Generate a test ID"
      (set_fact 
        (test_id (jinja "{{ lookup('password', '/dev/null chars=ascii_letters length=16') }}")))
      (when "test_id is not defined"))
    (task "Generate an org name"
      (set_fact 
        (org_name "AWX-Collection-tests-organization-org-" (jinja "{{ test_id }}"))
        (group_name1 "AWX-Collection-tests-instance_group-group1-" (jinja "{{ test_id }}"))))
    (task "Make sure " (jinja "{{ org_name }}") " is not there"
      (organization 
        (name (jinja "{{ org_name }}"))
        (state "absent"))
      (register "result"))
    (task "Create a new organization"
      (organization 
        (name (jinja "{{ org_name }}"))
        (galaxy_credentials (list
            "Ansible Galaxy")))
      (register "result"))
    (task
      (assert 
        (that "result is changed")))
    (task "Create a new organization with exists"
      (organization 
        (name (jinja "{{ org_name }}"))
        (galaxy_credentials (list
            "Ansible Galaxy"))
        (state "exists"))
      (register "result"))
    (task
      (assert 
        (that "result is not changed")))
    (task "Delete a new organization"
      (organization 
        (name (jinja "{{ org_name }}"))
        (galaxy_credentials (list
            "Ansible Galaxy"))
        (state "absent"))
      (register "result"))
    (task
      (assert 
        (that "result is changed")))
    (task "Create a new organization with exists"
      (organization 
        (name (jinja "{{ org_name }}"))
        (galaxy_credentials (list
            "Ansible Galaxy"))
        (state "exists"))
      (register "result"))
    (task
      (assert 
        (that "result is changed")))
    (task "Make sure making the same org is not a change"
      (organization 
        (name (jinja "{{ org_name }}")))
      (register "result"))
    (task
      (assert 
        (that (list
            "result is not changed"))))
    (task "Create an Instance Group"
      (instance_group 
        (name (jinja "{{ group_name1 }}"))
        (state "present"))
      (register "result"))
    (task
      (assert 
        (that (list
            "result is changed"))))
    (task "Pass in all parameters"
      (organization 
        (name (jinja "{{ org_name }}"))
        (description "A description")
        (instance_groups (list
            (jinja "{{ group_name1 }}"))))
      (register "result"))
    (task
      (assert 
        (that (list
            "result is changed"))))
    (task "Change the description"
      (organization 
        (name (jinja "{{ org_name }}"))
        (description "A new description"))
      (register "result"))
    (task
      (assert 
        (that (list
            "result is changed"))))
    (task "Delete the instance groups"
      (instance_group 
        (name (jinja "{{ group_name1 }}"))
        (state "absent")))
    (task "Rename the organization"
      (organization 
        (name (jinja "{{ org_name }}"))
        (new_name (jinja "{{ org_name }}") "a"))
      (register "result"))
    (task
      (assert 
        (that (list
            "result is changed"))))
    (task "Remove the organization"
      (organization 
        (name (jinja "{{ org_name }}") "a")
        (state "absent"))
      (register "result"))
    (task
      (assert 
        (that (list
            "result is changed"))))
    (task "Remove a missing organization"
      (organization 
        (name (jinja "{{ org_name }}"))
        (state "absent"))
      (register "result"))
    (task
      (assert 
        (that (list
            "result is not changed"))))
    (task "Check that SSL is available and verify_ssl is enabled (task must fail)"
      (organization 
        (name "Default")
        (validate_certs "true"))
      (ignore_errors "yes")
      (register "check_ssl_is_used"))
    (task "Check that connection failed"
      (assert 
        (that (list
            "'CERTIFICATE_VERIFY_FAILED' in check_ssl_is_used['msg']"))))
    (task "Check that verify_ssl is disabled (task must not fail)"
      (organization 
        (name "Default")
        (validate_certs "false")))))
