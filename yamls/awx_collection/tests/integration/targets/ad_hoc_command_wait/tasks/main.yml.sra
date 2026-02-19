(playbook "awx_collection/tests/integration/targets/ad_hoc_command_wait/tasks/main.yml"
  (tasks
    (task "Generate a random string for test"
      (set_fact 
        (test_id (jinja "{{ lookup('password', '/dev/null chars=ascii_letters length=16') }}")))
      (when "test_id is not defined"))
    (task "Generate names"
      (set_fact 
        (inv_name "AWX-Collection-tests-ad_hoc_command_wait-inventory-" (jinja "{{ test_id }}"))
        (ssh_cred_name "AWX-Collection-tests-ad_hoc_command_wait-ssh-cred-" (jinja "{{ test_id }}"))
        (org_name "AWX-Collection-tests-ad_hoc_command_wait-org-" (jinja "{{ test_id }}"))))
    (task "Create a New Organization"
      (organization 
        (name (jinja "{{ org_name }}"))))
    (task "Create an Inventory"
      (inventory 
        (name (jinja "{{ inv_name }}"))
        (organization (jinja "{{ org_name }}"))
        (state "present")))
    (task "Add localhost to the Inventory"
      (host 
        (name "localhost")
        (inventory (jinja "{{ inv_name }}"))
        (variables 
          (ansible_connection "local"))))
    (task "Create a Credential"
      (credential 
        (name (jinja "{{ ssh_cred_name }}"))
        (organization (jinja "{{ org_name }}"))
        (credential_type "Machine")
        (state "present")))
    (task "Check module fails with correct msg"
      (ad_hoc_command_wait 
        (command_id "99999999"))
      (register "result")
      (ignore_errors "yes"))
    (task
      (assert 
        (that (list
            "result is failed"
            "result.msg == 'Unable to wait on ad hoc command 99999999; that ID does not exist.'"))))
    (task "Launch command module with sleep 10"
      (ad_hoc_command 
        (inventory (jinja "{{ inv_name }}"))
        (credential (jinja "{{ ssh_cred_name }}"))
        (module_name "command")
        (module_args "sleep 5"))
      (register "command"))
    (task
      (assert 
        (that (list
            "command is changed"))))
    (task "Wait for the Job to finish"
      (ad_hoc_command_wait 
        (command_id (jinja "{{ command.id }}")))
      (register "wait_results"))
    (task
      (assert 
        (that (list
            "wait_results is successful"
            "'elapsed' in wait_results"
            "'id' in wait_results"))))
    (task "Launch a long running command"
      (ad_hoc_command 
        (inventory (jinja "{{ inv_name }}"))
        (credential (jinja "{{ ssh_cred_name }}"))
        (module_name "command")
        (module_args "sleep 10000"))
      (register "command"))
    (task
      (assert 
        (that (list
            "command is changed"))))
    (task "Timeout waiting for the command to complete"
      (ad_hoc_command_wait 
        (command_id (jinja "{{ command.id }}"))
        (timeout "1"))
      (ignore_errors "yes")
      (register "wait_results"))
    (task
      (assert 
        (that (list
            "('Monitoring of ad hoc command -' in wait_results.msg and 'aborted due to timeout' in wait_results.msg) or ('Timeout waiting for command to finish.' in wait_results.msg)"
            "'id' in wait_results"))))
    (task "Async cancel the long-running command"
      (ad_hoc_command_cancel 
        (command_id (jinja "{{ command.id }}")))
      (async "3600")
      (poll "0"))
    (task "Wait for the command to exit on cancel"
      (ad_hoc_command_wait 
        (command_id (jinja "{{ command.id }}")))
      (register "wait_results")
      (ignore_errors "yes"))
    (task
      (assert 
        (that (list
            "wait_results.status in [\"successful\", \"canceled\"]"))
        (fail_msg "Ad hoc command stdout: " (jinja "{{ lookup('awx.awx.controller_api', 'ad_hoc_commands/' + command.id | string + '/stdout/?format=json') }}"))
        (success_msg "Ad hoc command finished with status " (jinja "{{ wait_results.status }}"))))
    (task "Delete the Credential"
      (credential 
        (name (jinja "{{ ssh_cred_name }}"))
        (organization (jinja "{{ org_name }}"))
        (credential_type "Machine")
        (state "absent")))
    (task "Delete the Inventory"
      (inventory 
        (name (jinja "{{ inv_name }}"))
        (organization (jinja "{{ org_name }}"))
        (state "absent")))
    (task "Remove the Organization"
      (organization 
        (name (jinja "{{ org_name }}"))
        (state "absent")))))
