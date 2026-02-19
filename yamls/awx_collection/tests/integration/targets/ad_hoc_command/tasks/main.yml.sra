(playbook "awx_collection/tests/integration/targets/ad_hoc_command/tasks/main.yml"
  (tasks
    (task "Generate a random string for test"
      (set_fact 
        (test_id (jinja "{{ lookup('password', '/dev/null chars=ascii_letters length=16') }}")))
      (when "test_id is not defined"))
    (task "Generate names"
      (set_fact 
        (inv_name "AWX-Collection-tests-ad_hoc_command-inventory-" (jinja "{{ test_id }}"))
        (ssh_cred_name "AWX-Collection-tests-ad_hoc_command-ssh-cred-" (jinja "{{ test_id }}"))
        (org_name "AWX-Collection-tests-ad_hoc_command-org-" (jinja "{{ test_id }}"))
        (ee_name "AWX-Collection-tests-ad_hoc_command-ee-" (jinja "{{ test_id }}"))))
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
    (task "Create an Execution Environment"
      (execution_environment 
        (name (jinja "{{ ee_name }}"))
        (organization (jinja "{{ org_name }}"))
        (description "EE for Testing")
        (image "quay.io/ansible/awx-ee")
        (pull "always")
        (state "present"))
      (register "result_ee"))
    (task "Launch an Ad Hoc Command waiting for it to finish"
      (ad_hoc_command 
        (inventory (jinja "{{ inv_name }}"))
        (credential (jinja "{{ ssh_cred_name }}"))
        (module_name "command")
        (module_args "echo I <3 Ansible")
        (wait "true"))
      (register "result"))
    (task
      (assert 
        (that (list
            "result is changed"
            "result.status == 'successful'"))))
    (task "Launch an Ad Hoc Command without module argument"
      (ad_hoc_command 
        (inventory "Demo Inventory")
        (credential (jinja "{{ ssh_cred_name }}"))
        (module_name "ping")
        (wait "true"))
      (register "result"))
    (task
      (assert 
        (that (list
            "result is changed"
            "result.status == 'successful'"))))
    (task "Launch an Ad Hoc Command with extra_vars"
      (ad_hoc_command 
        (inventory "Demo Inventory")
        (credential (jinja "{{ ssh_cred_name }}"))
        (module_name "ping")
        (extra_vars 
          (var1 "test var"))
        (wait "true"))
      (register "result"))
    (task
      (assert 
        (that (list
            "result is changed"
            "result.status == 'successful'"))))
    (task "Launch an Ad Hoc Command with Execution Environment specified"
      (ad_hoc_command 
        (inventory "Demo Inventory")
        (credential (jinja "{{ ssh_cred_name }}"))
        (execution_environment (jinja "{{ ee_name }}"))
        (module_name "ping")
        (wait "true"))
      (register "result"))
    (task
      (assert 
        (that (list
            "result is changed"
            "result.status == 'successful'"
            "lookup('awx.awx.controller_api', 'ad_hoc_commands/' ~  result.id)['execution_environment'] == result_ee.id"))))
    (task "Check module fails with correct msg"
      (ad_hoc_command 
        (inventory (jinja "{{ inv_name }}"))
        (credential (jinja "{{ ssh_cred_name }}"))
        (module_name "Does not exist"))
      (register "result")
      (ignore_errors "yes"))
    (task
      (assert 
        (that (list
            "result is failed"
            "result is not changed"
            "'Does not exist' in result.response['json']['module_name'][0]"))))
    (task "Delete the Execution Environment"
      (execution_environment 
        (name (jinja "{{ ee_name }}"))
        (organization (jinja "{{ org_name }}"))
        (image "quay.io/ansible/awx-ee")
        (state "absent")))
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
