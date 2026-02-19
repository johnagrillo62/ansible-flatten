(playbook "awx_collection/tests/integration/targets/user/tasks/main.yml"
  (tasks
    (task "Generate a test ID"
      (ansible.builtin.set_fact 
        (test_id (jinja "{{ lookup('password', '/dev/null chars=ascii_letters length=16') }}")))
      (when "test_id is not defined"))
    (task "Generate names"
      (ansible.builtin.set_fact 
        (username "AWX-Collection-tests-user-user-" (jinja "{{ test_id }}"))))
    (task "Create a User"
      (awx.awx.user 
        (username (jinja "{{ username }}"))
        (first_name "Joe")
        (password (jinja "{{ 65535 | random | to_uuid }}"))
        (state "present"))
      (register "result"))
    (task "Assert result changed"
      (ansible.builtin.assert 
        (that (list
            "result.changed"))))
    (task "Create a User with exists"
      (awx.awx.user 
        (username (jinja "{{ username }}"))
        (first_name "Joe")
        (password (jinja "{{ 65535 | random | to_uuid }}"))
        (state "exists"))
      (register "result"))
    (task "Assert results did not change"
      (ansible.builtin.assert 
        (that (list
            "not result.changed"))))
    (task "Delete a User"
      (awx.awx.user 
        (username (jinja "{{ username }}"))
        (first_name "Joe")
        (password (jinja "{{ 65535 | random | to_uuid }}"))
        (state "absent"))
      (register "result"))
    (task "Assert result changed"
      (ansible.builtin.assert 
        (that (list
            "result.changed"))))
    (task "Create a User with exists"
      (awx.awx.user 
        (username (jinja "{{ username }}"))
        (first_name "Joe")
        (password (jinja "{{ 65535 | random | to_uuid }}"))
        (state "exists"))
      (register "result"))
    (task "Assert result changed"
      (ansible.builtin.assert 
        (that (list
            "result.changed"))))
    (task "Change a User by ID"
      (awx.awx.user 
        (username (jinja "{{ result.id }}"))
        (last_name "User")
        (email "joe@example.org")
        (state "present"))
      (register "result"))
    (task "Assert result changed"
      (ansible.builtin.assert 
        (that (list
            "result.changed"))))
    (task "Check idempotency"
      (awx.awx.user 
        (username (jinja "{{ username }}"))
        (first_name "Joe")
        (last_name "User"))
      (register "result"))
    (task "Assert result did not change"
      (ansible.builtin.assert 
        (that (list
            "not (result.changed)"))))
    (task "Rename a User"
      (awx.awx.user 
        (username (jinja "{{ username }}"))
        (new_username (jinja "{{ username }}") "-renamed")
        (email "joe@example.org"))
      (register "result"))
    (task "Assert result changed"
      (ansible.builtin.assert 
        (that (list
            "result.changed"))))
    (task "Delete a User"
      (awx.awx.user 
        (username (jinja "{{ username }}") "-renamed")
        (email "joe@example.org")
        (state "absent"))
      (register "result"))
    (task "Assert result changed"
      (ansible.builtin.assert 
        (that (list
            "result.changed"))))
    (task "Create an Auditor"
      (awx.awx.user 
        (first_name "Joe")
        (last_name "Auditor")
        (username (jinja "{{ username }}"))
        (password (jinja "{{ 65535 | random | to_uuid }}"))
        (email "joe@example.org")
        (state "present")
        (auditor "true"))
      (register "result"))
    (task "Assert result changed"
      (ansible.builtin.assert 
        (that (list
            "result.changed"))))
    (task "Delete an Auditor"
      (awx.awx.user 
        (username (jinja "{{ username }}"))
        (email "joe@example.org")
        (state "absent"))
      (register "result"))
    (task "Assert result changed"
      (ansible.builtin.assert 
        (that (list
            "result.changed"))))
    (task "Create a Superuser"
      (awx.awx.user 
        (first_name "Joe")
        (last_name "Super")
        (username (jinja "{{ username }}"))
        (password (jinja "{{ 65535 | random | to_uuid }}"))
        (email "joe@example.org")
        (state "present")
        (superuser "true"))
      (register "result"))
    (task "Assert result changed"
      (ansible.builtin.assert 
        (that (list
            "result.changed"))))
    (task "Delete a Superuser"
      (awx.awx.user 
        (username (jinja "{{ username }}"))
        (email "joe@example.org")
        (state "absent"))
      (register "result"))
    (task "Assert result changed"
      (ansible.builtin.assert 
        (that (list
            "result.changed"))))
    (task "Test SSL parameter"
      (awx.awx.user 
        (first_name "Joe")
        (last_name "User")
        (username (jinja "{{ username }}"))
        (password (jinja "{{ 65535 | random | to_uuid }}"))
        (email "joe@example.org")
        (state "present")
        (validate_certs "true")
        (controller_host "http://foo.invalid"))
      (ignore_errors "true")
      (register "result"))
    (task "Assert SSL parameter failure message is meaningful"
      (ansible.builtin.assert 
        (that (list
            "result is failed or result.failed | default(false)"))))
    (task "Org tasks"
      (block (list
          
          (name "Generate an org name")
          (ansible.builtin.set_fact 
            (org_name "AWX-Collection-tests-organization-org-" (jinja "{{ test_id }}")))
          
          (name "Make sure organization is absent")
          (organization 
            (name (jinja "{{ org_name }}"))
            (state "absent"))
          (register "result")
          
          (name "Create a new Organization")
          (organization 
            (name (jinja "{{ org_name }}"))
            (galaxy_credentials (list
                "Ansible Galaxy")))
          (register "result")
          
          (name "Assert result changed")
          (ansible.builtin.assert 
            (that "result.changed"))
          
          (name "Create a User to become admin of an organization")
          (awx.awx.user 
            (username (jinja "{{ username }}") "-orgadmin")
            (password (jinja "{{ username }}") "-orgadmin")
            (state "present")
            (organization (jinja "{{ org_name }}")))
          (register "result")
          
          (name "Assert result changed")
          (ansible.builtin.assert 
            (that (list
                "result.changed")))
          
          (name "Add the user -orgadmin as an admin of the organization")
          (awx.awx.role 
            (user (jinja "{{ username }}") "-orgadmin")
            (role "admin")
            (organization (jinja "{{ org_name }}"))
            (state "present"))
          (register "result")
          
          (name "Assert that user was added as org admin")
          (ansible.builtin.assert 
            (that (list
                "result.changed | default(false)")))
          
          (name "Create a User as -orgadmin without using an organization (must fail)")
          (awx.awx.user 
            (controller_username (jinja "{{ username }}") "-orgadmin")
            (controller_password (jinja "{{ username }}") "-orgadmin")
            (username (jinja "{{ username }}"))
            (first_name "Joe")
            (password (jinja "{{ 65535 | random | to_uuid }}"))
            (state "present"))
          (register "result")
          (ignore_errors "true")
          
          (name "Assert result failed")
          (ansible.builtin.assert 
            (that (list
                "result is defined"
                "result.failed is defined"
                "result.failed | bool"))
            (fail_msg "The task did not fail as expected.")
            (success_msg "The task failed as expected."))
          
          (name "Create a User as -orgadmin using an organization")
          (awx.awx.user 
            (controller_username (jinja "{{ username }}") "-orgadmin")
            (controller_password (jinja "{{ username }}") "-orgadmin")
            (username (jinja "{{ username }}"))
            (first_name "Joe")
            (password (jinja "{{ 65535 | random | to_uuid }}"))
            (state "present")
            (organization (jinja "{{ org_name }}")))
          (register "result")
          
          (name "Assert result changed")
          (ansible.builtin.assert 
            (that (list
                "result.changed")))
          
          (name "Change a User as -orgadmin by ID using an organization")
          (awx.awx.user 
            (controller_username (jinja "{{ username }}") "-orgadmin")
            (controller_password (jinja "{{ username }}") "-orgadmin")
            (username (jinja "{{ result.id }}"))
            (last_name "User")
            (email "joe@example.org")
            (state "present")
            (organization (jinja "{{ org_name }}")))
          (register "result")
          
          (name "Assert result changed")
          (ansible.builtin.assert 
            (that (list
                "result.changed")))
          
          (name "Check idempotency as -orgadmin using an organization")
          (awx.awx.user 
            (controller_username (jinja "{{ username }}") "-orgadmin")
            (controller_password (jinja "{{ username }}") "-orgadmin")
            (username (jinja "{{ username }}"))
            (first_name "Joe")
            (last_name "User")
            (organization (jinja "{{ org_name }}")))
          (register "result")
          
          (name "Assert result did not change")
          (ansible.builtin.assert 
            (that (list
                "not (result.changed)")))
          
          (name "Rename a User as -orgadmin using an organization")
          (awx.awx.user 
            (controller_username (jinja "{{ username }}") "-orgadmin")
            (controller_password (jinja "{{ username }}") "-orgadmin")
            (username (jinja "{{ username }}"))
            (new_username (jinja "{{ username }}") "-renamed")
            (email "joe@example.org")
            (organization (jinja "{{ org_name }}")))
          (register "result")
          
          (name "Assert result changed")
          (ansible.builtin.assert 
            (that (list
                "result.changed")))
          
          (name "Delete a User as -orgadmin using an organization")
          (awx.awx.user 
            (controller_username (jinja "{{ username }}") "-orgadmin")
            (controller_password (jinja "{{ username }}") "-orgadmin")
            (username (jinja "{{ username }}") "-renamed")
            (email "joe@example.org")
            (state "absent")
            (organization (jinja "{{ org_name }}")))
          (register "result")
          
          (name "Assert result changed")
          (ansible.builtin.assert 
            (that (list
                "result.changed")))
          
          (name "Remove the user -orgadmin as an admin of the organization")
          (role 
            (user (jinja "{{ username }}") "-orgadmin")
            (role "admin")
            (organization (jinja "{{ org_name }}"))
            (state "absent"))
          (register "result")
          
          (name "Assert result changed")
          (ansible.builtin.assert 
            (that (list
                "result.changed")))
          
          (name "Delete the User -orgadmin")
          (awx.awx.user 
            (username (jinja "{{ username }}") "-orgadmin")
            (password (jinja "{{ username }}") "-orgadmin")
            (state "absent")
            (organization (jinja "{{ org_name }}")))
          (register "result")
          
          (name "Assert result changed")
          (ansible.builtin.assert 
            (that (list
                "result.changed")))
          
          (name "Delete the Organization " (jinja "{{ org_name }}"))
          (organization 
            (name (jinja "{{ org_name }}"))
            (state "absent"))
          (register "result")
          
          (name "Assert result changed")
          (ansible.builtin.assert 
            (that "result.changed")))))))
