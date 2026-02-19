(playbook "awx_collection/tests/integration/targets/credential/tasks/main.yml"
  (tasks
    (task "Generate a random string for test"
      (set_fact 
        (test_id (jinja "{{ lookup('password', '/dev/null chars=ascii_letters length=16') }}")))
      (when "test_id is not defined"))
    (task "Generate names"
      (set_fact 
        (ssh_cred_name1 "AWX-Collection-tests-credential-ssh-cred1-" (jinja "{{ test_id }}"))
        (ssh_cred_name2 "AWX-Collection-tests-credential-ssh-cred2-" (jinja "{{ test_id }}"))
        (ssh_cred_name3 "AWX-Collection-tests-credential-ssh-cred-lookup-source-" (jinja "{{ test_id }}"))
        (ssh_cred_name4 "AWX-Collection-tests-credential-ssh-cred-file-source-" (jinja "{{ test_id }}"))
        (vault_cred_name1 "AWX-Collection-tests-credential-vault-cred1-" (jinja "{{ test_id }}"))
        (vault_cred_name2 "AWX-Collection-tests-credential-vault-ssh-cred1-" (jinja "{{ test_id }}"))
        (net_cred_name1 "AWX-Collection-tests-credential-net-cred1-" (jinja "{{ test_id }}"))
        (scm_cred_name1 "AWX-Collection-tests-credential-scm-cred1-" (jinja "{{ test_id }}"))
        (aws_cred_name1 "AWX-Collection-tests-credential-aws-cred1-" (jinja "{{ test_id }}"))
        (vmware_cred_name1 "AWX-Collection-tests-credential-vmware-cred1-" (jinja "{{ test_id }}"))
        (sat6_cred_name1 "AWX-Collection-tests-credential-sat6-cred1-" (jinja "{{ test_id }}"))
        (gce_cred_name1 "AWX-Collection-tests-credential-gce-cred1-" (jinja "{{ test_id }}"))
        (azurerm_cred_name1 "AWX-Collection-tests-credential-azurerm-cred1-" (jinja "{{ test_id }}"))
        (openstack_cred_name1 "AWX-Collection-tests-credential-openstack-cred1-" (jinja "{{ test_id }}"))
        (rhv_cred_name1 "AWX-Collection-tests-credential-rhv-cred1-" (jinja "{{ test_id }}"))
        (insights_cred_name1 "AWX-Collection-tests-credential-insights-cred1-" (jinja "{{ test_id }}"))
        (insights_cred_name2 "AWX-Collection-tests-credential-insights-cred2-" (jinja "{{ test_id }}"))
        (tower_cred_name1 "AWX-Collection-tests-credential-tower-cred1-" (jinja "{{ test_id }}"))))
    (task "Get current Credential Types available"
      (ansible.builtin.set_fact 
        (credentials (jinja "{{ lookup('awx.awx.controller_api', 'credential_types') }}"))))
    (task "Register Credentials found"
      (set_fact 
        (aws_found (jinja "{{ 'Amazon Web Services' in credentials | map(attribute='name') | list }}"))
        (vmware_found (jinja "{{ 'VMware vCenter' in credentials | map(attribute='name') | list }}"))
        (azure_found (jinja "{{ 'Microsoft Azure Resource Manager' in credentials | map(attribute='name') | list }}"))
        (gce_found (jinja "{{ 'Google Compute Engine' in credentials | map(attribute='name') | list }}"))
        (insights_found (jinja "{{ 'Red Hat Insights' in credentials | map(attribute='name') | list }}"))
        (satellite_found (jinja "{{ 'Red Hat Satellite 6' in credentials | map(attribute='name') | list }}"))
        (openstack_found (jinja "{{ 'OpenStack' in credentials | map(attribute='name') | list }}"))
        (rhv_found (jinja "{{ 'Red Hat Virtualization' in credentials | map(attribute='name') | list }}"))))
    (task "create a tempdir for an SSH key"
      (local_action "shell mktemp -d")
      (register "tempdir"))
    (task "Generate a local SSH key"
      (local_action "shell ssh-keygen -b 2048 -t rsa -f " (jinja "{{ tempdir.stdout }}") "/id_rsa -q -N 'passphrase'"))
    (task "Read the generated key"
      (set_fact 
        (ssh_key_data (jinja "{{ lookup('file', tempdir.stdout + '/id_rsa') }}"))))
    (task "Create an Org-specific credential with an ID"
      (credential 
        (name (jinja "{{ ssh_cred_name1 }}"))
        (organization "Default")
        (credential_type "Machine")
        (state "present"))
      (register "result"))
    (task
      (assert 
        (that (list
            "result is changed"))))
    (task "Create an Org-specific credential with an ID with exists"
      (credential 
        (name (jinja "{{ ssh_cred_name1 }}"))
        (organization "Default")
        (credential_type "Machine")
        (state "exists"))
      (register "result"))
    (task
      (assert 
        (that (list
            "result is not changed"))))
    (task "Delete an Org-specific credential with an ID"
      (credential 
        (name (jinja "{{ ssh_cred_name1 }}"))
        (organization "Default")
        (credential_type "Machine")
        (state "absent"))
      (register "result"))
    (task
      (assert 
        (that (list
            "result is changed"))))
    (task "Delete a credential without credential_type"
      (credential 
        (name (jinja "{{ ssh_cred_name1 }}"))
        (organization "Default")
        (state "absent"))
      (register "result")
      (ignore_errors "yes"))
    (task
      (assert 
        (that (list
            "result is failed"))))
    (task "Create an Org-specific credential with an ID with exists"
      (credential 
        (name (jinja "{{ ssh_cred_name1 }}"))
        (organization "Default")
        (credential_type "Machine")
        (state "exists"))
      (register "result"))
    (task
      (assert 
        (that (list
            "result is changed"))))
    (task "Delete a Org-specific credential"
      (credential 
        (name (jinja "{{ ssh_cred_name1 }}"))
        (organization "Default")
        (state "absent")
        (credential_type "Machine"))
      (register "result"))
    (task
      (assert 
        (that (list
            "result is changed"))))
    (task "Create the User-specific credential"
      (credential 
        (name (jinja "{{ ssh_cred_name1 }}"))
        (user "admin")
        (credential_type "Machine")
        (state "present"))
      (register "result"))
    (task
      (assert 
        (that (list
            "result is changed"))))
    (task "Delete a User-specific credential"
      (credential 
        (name (jinja "{{ ssh_cred_name1 }}"))
        (user "admin")
        (state "absent")
        (credential_type "Machine"))
      (register "result"))
    (task
      (assert 
        (that (list
            "result is changed"))))
    (task "Create a valid SSH credential"
      (credential 
        (name (jinja "{{ ssh_cred_name2 }}"))
        (organization "Default")
        (state "present")
        (credential_type "Machine")
        (description "An example SSH credential")
        (inputs 
          (username "joe")
          (password "secret")
          (become_method "sudo")
          (become_username "superuser")
          (become_password "supersecret")
          (ssh_key_data (jinja "{{ ssh_key_data }}"))
          (ssh_key_unlock "passphrase")))
      (register "result"))
    (task
      (assert 
        (that (list
            "result is changed"))))
    (task "Create a valid SSH credential"
      (credential 
        (name (jinja "{{ ssh_cred_name2 }}"))
        (organization "Default")
        (state "present")
        (credential_type "Machine")
        (description "An example SSH credential")
        (inputs 
          (username "joe")
          (become_method "sudo")
          (become_username "superuser")))
      (register "result"))
    (task
      (assert 
        (that (list
            "result is changed"))))
    (task "Check for inputs idempotency (when \"inputs\" is blank)"
      (credential 
        (name (jinja "{{ ssh_cred_name2 }}"))
        (organization "Default")
        (state "present")
        (credential_type "Machine")
        (description "An example SSH credential"))
      (register "result"))
    (task
      (assert 
        (that (list
            "result is not changed"))))
    (task "Copy ssh Credential"
      (credential 
        (name "copy_" (jinja "{{ ssh_cred_name2 }}"))
        (copy_from (jinja "{{ ssh_cred_name2 }}"))
        (credential_type "Machine"))
      (register "result"))
    (task
      (assert 
        (that (list
            "result.copied"))))
    (task "Delete an SSH credential"
      (credential 
        (name "copy_" (jinja "{{ ssh_cred_name2 }}"))
        (organization "Default")
        (state "absent")
        (credential_type "Machine"))
      (register "result"))
    (task
      (assert 
        (that (list
            "result is changed"))))
    (task "Create a valid SSH credential from lookup source"
      (credential 
        (name (jinja "{{ ssh_cred_name3 }}"))
        (organization "Default")
        (state "present")
        (credential_type "Machine")
        (description "An example SSH credential from lookup source")
        (inputs 
          (username "joe")
          (password "secret")
          (become_method "sudo")
          (become_username "superuser")
          (become_password "supersecret")
          (ssh_key_data (jinja "{{ lookup('file', tempdir.stdout + '/id_rsa') }}"))
          (ssh_key_unlock "passphrase")))
      (register "result"))
    (task
      (assert 
        (that (list
            "result is changed"))))
    (task "Delete an SSH credential"
      (credential 
        (name (jinja "{{ ssh_cred_name2 }}"))
        (organization "Default")
        (state "absent")
        (credential_type "Machine"))
      (register "result"))
    (task
      (assert 
        (that (list
            "result is changed"))))
    (task "Ensure existence of SSH credential"
      (credential 
        (name (jinja "{{ ssh_cred_name2 }}"))
        (organization "Default")
        (state "exists")
        (credential_type "Machine")
        (description "An example SSH awx.awx.credential")
        (inputs 
          (username "joe")
          (password "secret")
          (become_method "sudo")
          (become_username "superuser")
          (become_password "supersecret")
          (ssh_key_data (jinja "{{ ssh_key_data }}"))
          (ssh_key_unlock "passphrase")))
      (register "result"))
    (task
      (assert 
        (that (list
            "result is changed"))))
    (task "Ensure existence of SSH credential, not updating any inputs"
      (credential 
        (name (jinja "{{ ssh_cred_name2 }}"))
        (organization "Default")
        (state "exists")
        (credential_type "Machine")
        (description "An example SSH awx.awx.credential")
        (inputs 
          (username "joe")
          (password "no-update-secret")
          (become_method "sudo")
          (become_username "some-other-superuser")
          (become_password "some-other-secret")
          (ssh_key_data (jinja "{{ ssh_key_data }}"))
          (ssh_key_unlock "another-pass-phrase")))
      (register "result"))
    (task
      (assert 
        (that (list
            "result is not changed"))))
    (task "Create an invalid SSH credential (passphrase required)"
      (credential 
        (name "SSH Credential")
        (organization "Default")
        (state "present")
        (credential_type "Machine")
        (inputs 
          (username "joe")
          (ssh_key_data (jinja "{{ ssh_key_data }}"))))
      (ignore_errors "yes")
      (register "result"))
    (task
      (assert 
        (that (list
            "result is failed"
            "'must be set when SSH key is encrypted' in result.msg"))))
    (task "Create an invalid SSH credential (Organization not found)"
      (credential 
        (name "SSH Credential")
        (organization "Missing_Organization")
        (state "present")
        (credential_type "Machine")
        (inputs 
          (username "joe")))
      (ignore_errors "yes")
      (register "result"))
    (task
      (assert 
        (that (list
            "result is failed"
            "result is not changed"
            "'Missing_Organization' in result.msg"
            "result.total_results == 0"))))
    (task "Delete an SSH credential"
      (credential 
        (name (jinja "{{ ssh_cred_name2 }}"))
        (organization "Default")
        (state "absent")
        (credential_type "Machine"))
      (register "result"))
    (task
      (assert 
        (that (list
            "result is changed"))))
    (task "Delete an SSH credential"
      (credential 
        (name (jinja "{{ ssh_cred_name3 }}"))
        (organization "Default")
        (state "absent")
        (credential_type "Machine"))
      (register "result"))
    (task
      (assert 
        (that (list
            "result is changed"))))
    (task "Delete an SSH credential"
      (credential 
        (name (jinja "{{ ssh_cred_name4 }}"))
        (organization "Default")
        (state "absent")
        (credential_type "Machine"))
      (register "result"))
    (task
      (assert 
        (that (list
            "result is not changed"))))
    (task "Create a valid Vault credential"
      (credential 
        (name (jinja "{{ vault_cred_name1 }}"))
        (organization "Default")
        (state "present")
        (credential_type "Vault")
        (description "An example Vault credential")
        (inputs 
          (vault_id "bar")
          (vault_password "secret-vault")))
      (register "result"))
    (task
      (assert 
        (that (list
            "result is changed"))))
    (task "Delete a Vault credential"
      (credential 
        (name (jinja "{{ vault_cred_name1 }}"))
        (organization "Default")
        (state "absent")
        (credential_type "Vault"))
      (register "result"))
    (task
      (assert 
        (that (list
            "result is changed"))))
    (task "Delete a Vault credential"
      (credential 
        (name (jinja "{{ vault_cred_name2 }}"))
        (organization "Default")
        (state "absent")
        (credential_type "Vault"))
      (register "result"))
    (task
      (assert 
        (that (list
            "result is not changed"))))
    (task "Create a valid Network credential"
      (credential 
        (name (jinja "{{ net_cred_name1 }}"))
        (organization "Default")
        (state "present")
        (credential_type "Network")
        (inputs 
          (username "joe")
          (password "secret")
          (authorize "true")
          (authorize_password "authorize-me")))
      (register "result"))
    (task
      (assert 
        (that (list
            "result is changed"))))
    (task "Delete a Network credential"
      (credential 
        (name (jinja "{{ net_cred_name1 }}"))
        (organization "Default")
        (state "absent")
        (credential_type "Network"))
      (register "result"))
    (task
      (assert 
        (that (list
            "result is changed"))))
    (task "Create a valid SCM credential"
      (credential 
        (name (jinja "{{ scm_cred_name1 }}"))
        (organization "Default")
        (state "present")
        (credential_type "Source Control")
        (inputs 
          (username "joe")
          (password "secret")
          (ssh_key_data (jinja "{{ ssh_key_data }}"))
          (ssh_key_unlock "passphrase")))
      (register "result"))
    (task
      (assert 
        (that (list
            "result is changed"))))
    (task "Delete an SCM credential"
      (credential 
        (name (jinja "{{ scm_cred_name1 }}"))
        (organization "Default")
        (state "absent")
        (credential_type "Source Control"))
      (register "result"))
    (task
      (assert 
        (that (list
            "result is changed"))))
    (task "Create a valid AWS credential"
      (credential 
        (name (jinja "{{ aws_cred_name1 }}"))
        (organization "Default")
        (state "present")
        (credential_type "Amazon Web Services")
        (inputs 
          (username "joe")
          (password "secret")
          (security_token "aws-token")))
      (register "result")
      (when "aws_found"))
    (task
      (assert 
        (that (list
            "result is changed")))
      (when "aws_found"))
    (task "Delete an AWS credential"
      (credential 
        (name (jinja "{{ aws_cred_name1 }}"))
        (organization "Default")
        (state "absent")
        (credential_type "Amazon Web Services"))
      (register "result")
      (when "aws_found"))
    (task
      (assert 
        (that (list
            "result is changed")))
      (when "aws_found"))
    (task "Create a valid VMWare credential"
      (credential 
        (name (jinja "{{ vmware_cred_name1 }}"))
        (organization "Default")
        (state "present")
        (credential_type "VMware vCenter")
        (inputs 
          (host "https://example.org")
          (username "joe")
          (password "secret")))
      (register "result")
      (when "vmware_found"))
    (task
      (assert 
        (that (list
            "result is changed")))
      (when "vmware_found"))
    (task "Delete an VMWare credential"
      (credential 
        (name (jinja "{{ vmware_cred_name1 }}"))
        (organization "Default")
        (state "absent")
        (credential_type "VMware vCenter"))
      (register "result")
      (when "vmware_found"))
    (task
      (assert 
        (that (list
            "result is changed")))
      (when "vmware_found"))
    (task "Create a valid Satellite6 credential"
      (credential 
        (name (jinja "{{ sat6_cred_name1 }}"))
        (organization "Default")
        (state "present")
        (credential_type "Red Hat Satellite 6")
        (inputs 
          (host "https://example.org")
          (username "joe")
          (password "secret")))
      (register "result")
      (when "satellite_found"))
    (task
      (assert 
        (that (list
            "result is changed")))
      (when "satellite_found"))
    (task "Delete a Satellite6 credential"
      (credential 
        (name (jinja "{{ sat6_cred_name1 }}"))
        (organization "Default")
        (state "absent")
        (credential_type "Red Hat Satellite 6"))
      (register "result")
      (when "satellite_found"))
    (task
      (assert 
        (that (list
            "result is changed")))
      (when "satellite_found"))
    (task "Create a valid GCE credential"
      (credential 
        (name (jinja "{{ gce_cred_name1 }}"))
        (organization "Default")
        (state "present")
        (credential_type "Google Compute Engine")
        (inputs 
          (username "joe")
          (project "ABC123")
          (ssh_key_data (jinja "{{ ssh_key_data }}"))))
      (register "result")
      (when "gce_found"))
    (task
      (assert 
        (that (list
            "result is changed")))
      (when "gce_found"))
    (task "Delete a GCE credential"
      (credential 
        (name (jinja "{{ gce_cred_name1 }}"))
        (organization "Default")
        (state "absent")
        (credential_type "Google Compute Engine"))
      (register "result")
      (when "gce_found"))
    (task
      (assert 
        (that (list
            "result is changed")))
      (when "gce_found"))
    (task "Create a valid AzureRM credential"
      (credential 
        (name (jinja "{{ azurerm_cred_name1 }}"))
        (organization "Default")
        (state "present")
        (credential_type "Microsoft Azure Resource Manager")
        (inputs 
          (username "joe")
          (password "secret")
          (subscription "some-subscription")))
      (register "result")
      (when "azure_found"))
    (task
      (assert 
        (that (list
            "result is changed")))
      (when "azure_found"))
    (task "Create a valid AzureRM credential with a tenant"
      (credential 
        (name (jinja "{{ azurerm_cred_name1 }}"))
        (organization "Default")
        (state "present")
        (credential_type "Microsoft Azure Resource Manager")
        (inputs 
          (client "some-client")
          (secret "some-secret")
          (tenant "some-tenant")
          (subscription "some-subscription")))
      (register "result")
      (when "azure_found"))
    (task
      (assert 
        (that (list
            "result is changed")))
      (when "azure_found"))
    (task "Delete an AzureRM credential"
      (credential 
        (name (jinja "{{ azurerm_cred_name1 }}"))
        (organization "Default")
        (state "absent")
        (credential_type "Microsoft Azure Resource Manager"))
      (register "result")
      (when "azure_found"))
    (task
      (assert 
        (that (list
            "result is changed")))
      (when "azure_found"))
    (task "Create a valid OpenStack credential"
      (credential 
        (name (jinja "{{ openstack_cred_name1 }}"))
        (organization "Default")
        (state "present")
        (credential_type "OpenStack")
        (inputs 
          (host "https://keystone.example.org")
          (username "joe")
          (password "secret")
          (project "tenant123")
          (domain "some-domain")))
      (register "result")
      (when "openstack_found"))
    (task
      (assert 
        (that (list
            "result is changed")))
      (when "openstack_found"))
    (task "Delete a OpenStack credential"
      (credential 
        (name (jinja "{{ openstack_cred_name1 }}"))
        (organization "Default")
        (state "absent")
        (credential_type "OpenStack"))
      (register "result")
      (when "openstack_found"))
    (task
      (assert 
        (that (list
            "result is changed")))
      (when "openstack_found"))
    (task "Create a valid RHV credential"
      (credential 
        (name (jinja "{{ rhv_cred_name1 }}"))
        (organization "Default")
        (state "present")
        (credential_type "Red Hat Virtualization")
        (inputs 
          (host "https://example.org")
          (username "joe")
          (password "secret")))
      (register "result")
      (when "rhv_found"))
    (task
      (assert 
        (that (list
            "result is changed")))
      (when "rhv_found"))
    (task "Delete an RHV credential"
      (credential 
        (name (jinja "{{ rhv_cred_name1 }}"))
        (organization "Default")
        (state "absent")
        (credential_type "Red Hat Virtualization"))
      (register "result")
      (when "rhv_found"))
    (task
      (assert 
        (that (list
            "result is changed")))
      (when "rhv_found"))
    (task "Create a valid Insights credential"
      (credential 
        (name (jinja "{{ insights_cred_name1 }}"))
        (organization "Default")
        (state "present")
        (credential_type "Insights")
        (inputs 
          (username "joe")
          (password "secret")))
      (register "result")
      (when "insights_found"))
    (task
      (assert 
        (that (list
            "result is changed")))
      (when "insights_found"))
    (task "Delete an Insights credential"
      (credential 
        (name (jinja "{{ insights_cred_name1 }}"))
        (organization "Default")
        (state "absent")
        (credential_type "Insights"))
      (register "result")
      (when "insights_found"))
    (task
      (assert 
        (that (list
            "result is changed")))
      (when "insights_found"))
    (task "Create a valid Insights token credential"
      (credential 
        (name (jinja "{{ insights_cred_name2 }}"))
        (organization "Default")
        (state "present")
        (credential_type "Insights")
        (inputs 
          (client_id "joe")
          (client_secret "secret")))
      (register "result")
      (when "insights_found"))
    (task
      (assert 
        (that (list
            "result is changed")))
      (when "insights_found"))
    (task "Delete an Insights token credential"
      (credential 
        (name (jinja "{{ insights_cred_name2 }}"))
        (organization "Default")
        (state "absent")
        (credential_type "Insights"))
      (register "result")
      (when "insights_found"))
    (task
      (assert 
        (that (list
            "result is changed")))
      (when "insights_found"))
    (task "Create a valid Tower-to-Tower credential"
      (credential 
        (name (jinja "{{ tower_cred_name1 }}"))
        (organization "Default")
        (state "present")
        (credential_type "Red Hat Ansible Automation Platform")
        (inputs 
          (host "https://controller.example.org")
          (username "joe")
          (password "secret")))
      (register "result"))
    (task
      (assert 
        (that (list
            "result is changed"))))
    (task "Delete a Tower-to-Tower credential"
      (credential 
        (name (jinja "{{ tower_cred_name1 }}"))
        (organization "Default")
        (state "absent")
        (credential_type "Red Hat Ansible Automation Platform"))
      (register "result"))
    (task
      (assert 
        (that (list
            "result is changed"))))
    (task "Check module fails with correct msg"
      (credential 
        (name "test-credential")
        (description "Credential Description")
        (credential_type "Machine")
        (organization "test-non-existing-org")
        (state "present"))
      (register "result")
      (ignore_errors "yes"))
    (task
      (assert 
        (that (list
            "result is failed"
            "result is not changed"
            "'test-non-existing-org' in result.msg"
            "result.total_results == 0"))))))
