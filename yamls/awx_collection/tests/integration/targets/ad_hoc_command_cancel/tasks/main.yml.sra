(playbook "awx_collection/tests/integration/targets/ad_hoc_command_cancel/tasks/main.yml"
  (tasks
    (task "Generate a random string for test"
      (ansible.builtin.set_fact 
        (test_id (jinja "{{ lookup('password', '/dev/null chars=ascii_letters length=16') }}")))
      (when "test_id is not defined"))
    (task "Generate names"
      (ansible.builtin.set_fact 
        (inv_name "AWX-Collection-tests-ad_hoc_command_cancel-inventory-" (jinja "{{ test_id }}"))
        (ssh_cred_name "AWX-Collection-tests-ad_hoc_command_cancel-ssh-cred-" (jinja "{{ test_id }}"))
        (org_name "AWX-Collection-tests-ad_hoc_command_cancel-org-" (jinja "{{ test_id }}"))))
    (task "Create a New Organization"
      (awx.awx.organization 
        (name (jinja "{{ org_name }}"))))
    (task "Create an Inventory"
      (awx.awx.inventory 
        (name (jinja "{{ inv_name }}"))
        (organization (jinja "{{ org_name }}"))
        (state "present")))
    (task "Add localhost to the Inventory"
      (awx.awx.host 
        (name "localhost")
        (inventory (jinja "{{ inv_name }}"))
        (variables 
          (ansible_connection "local"))))
    (task "Create a Credential"
      (awx.awx.credential 
        (name (jinja "{{ ssh_cred_name }}"))
        (organization (jinja "{{ org_name }}"))
        (credential_type "Machine")
        (state "present")))
    (task "Launch an Ad Hoc Command"
      (awx.awx.ad_hoc_command 
        (inventory (jinja "{{ inv_name }}"))
        (credential (jinja "{{ ssh_cred_name }}"))
        (module_name "command")
        (module_args "sleep 100"))
      (register "command"))
    (task
      (ansible.builtin.assert 
        (that (list
            "command is changed"))))
    (task "Cancel the command"
      (awx.awx.ad_hoc_command_cancel 
        (command_id (jinja "{{ command.id }}"))
        (request_timeout "60"))
      (register "results"))
    (task
      (ansible.builtin.assert 
        (that (list
            "results is changed"))))
    (task "Wait for up to a minute until the job enters the can_cancel: False state"
      (ansible.builtin.debug 
        (msg "The job can_cancel status has transitioned into False, we can proceed with testing"))
      (until "not job_status")
      (retries "6")
      (delay "10")
      (vars 
        (job_status (jinja "{{ lookup('awx.awx.controller_api', 'ad_hoc_commands/'+ command.id | string +'/cancel')['can_cancel'] }}"))))
    (task "Cancel the command with hard error if it's not running"
      (awx.awx.ad_hoc_command_cancel 
        (command_id (jinja "{{ command.id }}"))
        (fail_if_not_running "true"))
      (register "results")
      (ignore_errors "yes"))
    (task
      (ansible.builtin.assert 
        (that (list
            "results is failed"))))
    (task "Cancel an already canceled command (assert failure)"
      (awx.awx.ad_hoc_command_cancel 
        (command_id (jinja "{{ command.id }}"))
        (fail_if_not_running "true"))
      (register "results")
      (ignore_errors "yes"))
    (task
      (ansible.builtin.assert 
        (that (list
            "results is failed"))))
    (task "Check module fails with correct msg"
      (awx.awx.ad_hoc_command_cancel 
        (command_id "9999999999"))
      (register "result")
      (ignore_errors "yes"))
    (task
      (ansible.builtin.assert 
        (that (list
            "result.msg == 'Unable to find command with id 9999999999'"))))
    (task "Delete the Credential"
      (awx.awx.credential 
        (name (jinja "{{ ssh_cred_name }}"))
        (organization (jinja "{{ org_name }}"))
        (credential_type "Machine")
        (state "absent")))
    (task "Delete the Inventory"
      (awx.awx.inventory 
        (name (jinja "{{ inv_name }}"))
        (organization (jinja "{{ org_name }}"))
        (state "absent")))
    (task "Remove the Organization"
      (awx.awx.organization 
        (name (jinja "{{ org_name }}"))
        (state "absent")))))
