(playbook "awx_collection/tests/integration/targets/workflow_job_template/tasks/main.yml"
  (tasks
    (task "Generate a random string for names"
      (ansible.builtin.set_fact 
        (test_id (jinja "{{ lookup('password', '/dev/null chars=ascii_letters length=16') }}")))
      (when "test_id is not defined"))
    (task "Generate random names for test objects"
      (ansible.builtin.set_fact 
        (org_name "AWX-Collection-tests-organization-org-" (jinja "{{ test_id }}"))
        (scm_cred_name "AWX-Collection-tests-workflow_job_template-scm-cred-" (jinja "{{ test_id }}"))
        (demo_project_name "AWX-Collection-tests-workflow_job_template-proj-" (jinja "{{ test_id }}"))
        (demo_project_name_2 "AWX-Collection-tests-workflow_job_template-proj-" (jinja "{{ test_id }}") "_2")
        (jt1_name "AWX-Collection-tests-workflow_job_template-jt1-" (jinja "{{ test_id }}"))
        (jt2_name "AWX-Collection-tests-workflow_job_template-jt2-" (jinja "{{ test_id }}"))
        (approval_node_name "AWX-Collection-tests-workflow_approval_node-" (jinja "{{ test_id }}"))
        (lab1 "AWX-Collection-tests-job_template-lab1-" (jinja "{{ test_id }}"))
        (wfjt_name "AWX-Collection-tests-workflow_job_template-wfjt-" (jinja "{{ test_id }}"))
        (webhook_wfjt_name "AWX-Collection-tests-workflow_job_template-webhook-wfjt-" (jinja "{{ test_id }}"))
        (email_not "AWX-Collection-tests-job_template-email-not-" (jinja "{{ test_id }}"))
        (webhook_notification "AWX-Collection-tests-notification_template-wehbook-not-" (jinja "{{ test_id }}"))
        (project_inv "AWX-Collection-tests-inventory_source-inv-project-" (jinja "{{ test_id }}"))
        (project_inv_source "AWX-Collection-tests-inventory_source-inv-source-project-" (jinja "{{ test_id }}"))
        (github_webhook_credential_name "AWX-Collection-tests-credential-webhook-" (jinja "{{ test_id }}") "_github")
        (ee1 "AWX-Collection-tests-workflow_job_template-ee1-" (jinja "{{ test_id }}"))
        (label1 "AWX-Collection-tests-workflow_job_template-l1-" (jinja "{{ test_id }}"))
        (label2 "AWX-Collection-tests-workflow_job_template-l2-" (jinja "{{ test_id }}"))
        (ig1 "AWX-Collection-tests-workflow_job_template-ig1-" (jinja "{{ test_id }}"))
        (ig2 "AWX-Collection-tests-workflow_job_template-ig2-" (jinja "{{ test_id }}"))
        (host1 "AWX-Collection-tests-workflow_job_template-h1-" (jinja "{{ test_id }}"))))
    (task "Detect credential types"
      (ansible.builtin.set_fact 
        (credentials (jinja "{{ lookup('awx.awx.controller_api', 'credential_types') }}"))))
    (task "Register Credentials found"
      (ansible.builtin.set_fact 
        (github_found (jinja "{{ 'Github Personal Access Token' in credentials | map(attribute='name') | list }}"))
        (gitlab_found (jinja "{{ 'GitLab Personal Access Token' in credentials | map(attribute='name') | list }}"))))
    (task "Create initial resources for workflow job template tests"
      (block (list
          
          (name "Create a new organization")
          (awx.awx.organization 
            (name (jinja "{{ org_name }}"))
            (galaxy_credentials (list
                "Ansible Galaxy")))
          (register "result")
          
          (name "Create SCM Credential")
          (awx.awx.credential 
            (name (jinja "{{ scm_cred_name }}"))
            (organization "Default")
            (credential_type "Source Control"))
          (register "result")
          
          (name "Assert SCM credential created")
          (ansible.builtin.assert 
            (that (list
                "result.changed")))
          
          (name "Create Github PAT Credential")
          (awx.awx.credential 
            (name (jinja "{{ github_webhook_credential_name }}"))
            (organization "Default")
            (credential_type "Github Personal Access Token"))
          (register "result")
          (when "github_found")
          
          (name "Assert Github PAT credential created")
          (ansible.builtin.assert 
            (that (list
                "result.changed")))
          (when "github_found")
          
          (name "Add email notification")
          (awx.awx.notification_template 
            (name (jinja "{{ email_not }}"))
            (organization "Default")
            (notification_type "email")
            (notification_configuration 
              (username "user")
              (password "s3cr3t")
              (sender "tower@example.com")
              (recipients (list
                  "user1@example.com"))
              (host "smtp.example.com")
              (port "25")
              (use_tls "false")
              (use_ssl "false"))
            (state "present"))
          
          (name "Add webhook notification")
          (awx.awx.notification_template 
            (name (jinja "{{ webhook_notification }}"))
            (organization "Default")
            (notification_type "webhook")
            (notification_configuration 
              (url "http://www.example.com/hook")
              (headers 
                (X-Custom-Header "value123")))
            (state "present"))
          (register "result")
          
          (name "Create Labels for WFJT")
          (awx.awx.label 
            (name (jinja "{{ lab1 }}"))
            (organization (jinja "{{ item }}")))
          (loop (list
              "Default"
              (jinja "{{ org_name }}")))
          
          (name "Create a Demo Project")
          (awx.awx.project 
            (name (jinja "{{ demo_project_name }}"))
            (organization "Default")
            (state "present")
            (scm_type "git")
            (scm_url "https://github.com/ansible/ansible-tower-samples.git")
            (scm_credential (jinja "{{ scm_cred_name }}")))
          (register "result")
          
          (name "Assert demo project created")
          (ansible.builtin.assert 
            (that (list
                "result.changed")))
          
          (name "Create a 2nd Demo Project in another org")
          (awx.awx.project 
            (name (jinja "{{ demo_project_name_2 }}"))
            (organization (jinja "{{ org_name }}"))
            (state "present")
            (scm_type "git")
            (scm_url "https://github.com/ansible/ansible-tower-samples.git")
            (scm_credential (jinja "{{ scm_cred_name }}")))
          (register "result")
          
          (name "Assert 2nd demo project created")
          (ansible.builtin.assert 
            (that (list
                "result.changed")))
          
          (name "Create a 3rd Demo Project in another org with inventory source name")
          (awx.awx.project 
            (name (jinja "{{ project_inv_source }}"))
            (organization (jinja "{{ org_name }}"))
            (state "present")
            (scm_type "git")
            (scm_url "https://github.com/ansible/ansible-tower-samples.git")
            (scm_credential (jinja "{{ scm_cred_name }}")))
          (register "result")
          
          (name "Assert 3rd demo project created")
          (ansible.builtin.assert 
            (that (list
                "result.changed")))
          
          (name "Add an inventory")
          (awx.awx.inventory 
            (description "Test inventory")
            (organization "Default")
            (name (jinja "{{ project_inv }}")))
          
          (name "Create a source inventory")
          (awx.awx.inventory_source 
            (name (jinja "{{ project_inv_source }}"))
            (description "Source for Test inventory")
            (inventory (jinja "{{ project_inv }}"))
            (source_project (jinja "{{ demo_project_name }}"))
            (source_path "/inventories/inventory.ini")
            (overwrite "true")
            (source "scm"))
          (register "project_inv_source_result")
          
          (name "Assert inventory source created")
          (ansible.builtin.assert 
            (that (list
                "project_inv_source_result.changed")))
          
          (name "Add a node to demo inventory so we can use a slice count properly")
          (awx.awx.host 
            (name (jinja "{{ host1 }}"))
            (inventory "Demo Inventory")
            (variables 
              (ansible_connection "local")))
          (register "results")
          
          (name "Assert node added to inventory")
          (ansible.builtin.assert 
            (that (list
                "results.changed")))
          
          (name "Create a Job Template")
          (awx.awx.job_template 
            (name (jinja "{{ jt1_name }}"))
            (project (jinja "{{ demo_project_name }}"))
            (inventory "Demo Inventory")
            (ask_inventory_on_launch "true")
            (ask_credential_on_launch "true")
            (ask_labels_on_launch "true")
            (playbook "hello_world.yml")
            (job_type "run")
            (state "present"))
          (register "result")
          
          (name "Assert job template created")
          (ansible.builtin.assert 
            (that (list
                "result.changed")))
          
          (name "Create a second Job Template")
          (awx.awx.job_template 
            (name (jinja "{{ jt2_name }}"))
            (project (jinja "{{ demo_project_name }}"))
            (inventory "Demo Inventory")
            (playbook "hello_world.yml")
            (job_type "run")
            (state "present"))
          (register "result")
          
          (name "Assert second job template created")
          (ansible.builtin.assert 
            (that (list
                "result.changed")))
          
          (name "Create a second Job Template in new org")
          (awx.awx.job_template 
            (name (jinja "{{ jt2_name }}"))
            (project (jinja "{{ demo_project_name_2 }}"))
            (inventory "Demo Inventory")
            (playbook "hello_world.yml")
            (job_type "run")
            (state "present")
            (ask_execution_environment_on_launch "true")
            (ask_forks_on_launch "true")
            (ask_instance_groups_on_launch "true")
            (ask_timeout_on_launch "true")
            (ask_job_slice_count_on_launch "true")
            (ask_labels_on_launch "true"))
          (register "jt2_name_result")
          
          (name "Assert second job template in new org created")
          (ansible.builtin.assert 
            (that (list
                "jt2_name_result.changed")))
          
          (name "Add a Survey to second Job Template")
          (awx.awx.job_template 
            (name (jinja "{{ jt2_name }}"))
            (organization "Default")
            (project (jinja "{{ demo_project_name }}"))
            (inventory "Demo Inventory")
            (playbook "hello_world.yml")
            (job_type "run")
            (state "present")
            (survey_enabled "true")
            (survey_spec "{\"spec\": [{\"index\": 0, \"question_name\": \"my question?\", \"default\": \"mydef\", \"variable\": \"myvar\", \"type\": \"text\", \"required\": false}], \"description\": \"test\", \"name\": \"test\"}")
            (ask_execution_environment_on_launch "true")
            (ask_forks_on_launch "true")
            (ask_instance_groups_on_launch "true")
            (ask_timeout_on_launch "true")
            (ask_job_slice_count_on_launch "true")
            (ask_labels_on_launch "true"))
          (register "result")
          
          (name "Assert survey added to job template")
          (ansible.builtin.assert 
            (that (list
                "result.changed")))
          
          (name "Create a workflow job template")
          (awx.awx.workflow_job_template 
            (name (jinja "{{ wfjt_name }}"))
            (organization "Default")
            (inventory "Demo Inventory")
            (extra_vars 
              (foo "bar")
              (another-foo 
                (barz "bar2")))
            (labels (list
                (jinja "{{ lab1 }}")))
            (ask_inventory_on_launch "true")
            (ask_scm_branch_on_launch "true")
            (ask_limit_on_launch "true")
            (ask_tags_on_launch "true")
            (ask_variables_on_launch "true"))
          (register "result")
          
          (name "Assert workflow job template created")
          (ansible.builtin.assert 
            (that (list
                "result.changed == true")))
          
          (name "Create a workflow job template with exists")
          (awx.awx.workflow_job_template 
            (name (jinja "{{ wfjt_name }}"))
            (organization "Default")
            (inventory "Demo Inventory")
            (extra_vars 
              (foo "bar")
              (another-foo 
                (barz "bar2")))
            (labels (list
                (jinja "{{ lab1 }}")))
            (ask_inventory_on_launch "true")
            (ask_scm_branch_on_launch "true")
            (ask_limit_on_launch "true")
            (ask_tags_on_launch "true")
            (ask_variables_on_launch "true")
            (state "exists"))
          (register "result")
          
          (name "Assert workflow job template with exists did not change")
          (ansible.builtin.assert 
            (that (list
                "not result.changed")))
          
          (name "Delete a workflow job template")
          (awx.awx.workflow_job_template 
            (name (jinja "{{ wfjt_name }}"))
            (organization "Default")
            (inventory "Demo Inventory")
            (extra_vars 
              (foo "bar")
              (another-foo 
                (barz "bar2")))
            (labels (list
                (jinja "{{ lab1 }}")))
            (ask_inventory_on_launch "true")
            (ask_scm_branch_on_launch "true")
            (ask_limit_on_launch "true")
            (ask_tags_on_launch "true")
            (ask_variables_on_launch "true")
            (state "absent"))
          (register "result")
          
          (name "Assert workflow job template deleted")
          (ansible.builtin.assert 
            (that (list
                "result.changed")))
          
          (name "Create a workflow job template with exists")
          (awx.awx.workflow_job_template 
            (name (jinja "{{ wfjt_name }}"))
            (organization "Default")
            (inventory "Demo Inventory")
            (extra_vars 
              (foo "bar")
              (another-foo 
                (barz "bar2")))
            (ask_inventory_on_launch "true")
            (ask_scm_branch_on_launch "true")
            (ask_limit_on_launch "true")
            (ask_tags_on_launch "true")
            (ask_variables_on_launch "true")
            (state "exists"))
          (register "result")
          
          (name "Assert workflow job template with exists created")
          (ansible.builtin.assert 
            (that (list
                "result.changed")))
          
          (name "Create a workflow job template with bad label")
          (awx.awx.workflow_job_template 
            (name (jinja "{{ wfjt_name }}"))
            (organization "Default")
            (inventory "Demo Inventory")
            (extra_vars 
              (foo "bar")
              (another-foo 
                (barz "bar2")))
            (labels (list
                "label_bad"))
            (ask_inventory_on_launch "true")
            (ask_scm_branch_on_launch "true")
            (ask_limit_on_launch "true")
            (ask_tags_on_launch "true")
            (ask_variables_on_launch "true"))
          (register "results")
          (ignore_errors "true")
          
          (name "Assert creation failed due to bad label")
          (ansible.builtin.assert 
            (that (list
                "results.failed")))
          
          (name "Turn ask_* settings OFF")
          (awx.awx.workflow_job_template 
            (name (jinja "{{ wfjt_name }}"))
            (ask_inventory_on_launch "false")
            (ask_scm_branch_on_launch "false")
            (ask_limit_on_launch "false")
            (ask_tags_on_launch "false")
            (ask_variables_on_launch "false")
            (state "present"))
          
          (name "Assert ask settings are off")
          (ansible.builtin.assert 
            (that (list
                "result.changed")))
          
          (name "Create Labels")
          (awx.awx.label 
            (name (jinja "{{ item }}"))
            (organization "Default"))
          (loop (list
              (jinja "{{ label1 }}")
              (jinja "{{ label2 }}")))
          
          (name "Create an execution environment")
          (awx.awx.execution_environment 
            (name (jinja "{{ ee1 }}"))
            (image "junk"))
          
          (name "Create instance groups")
          (awx.awx.instance_group 
            (name (jinja "{{ item }}")))
          (loop (list
              (jinja "{{ ig1 }}")
              (jinja "{{ ig2 }}")))
          
          (name "Create leaf node")
          (awx.awx.workflow_job_template_node 
            (identifier "leaf")
            (unified_job_template (jinja "{{ jt2_name }}"))
            (lookup_organization (jinja "{{ org_name }}"))
            (workflow (jinja "{{ wfjt_name }}"))
            (execution_environment (jinja "{{ ee1 }}"))
            (forks "12")
            (instance_groups (list
                (jinja "{{ ig1 }}")
                (jinja "{{ ig2 }}")))
            (job_slice_count "2")
            (labels (list
                (jinja "{{ label1 }}")
                (jinja "{{ label2 }}")))
            (timeout "23"))
          (register "results")
          
          (name "Assert leaf node created")
          (ansible.builtin.assert 
            (that (list
                "results.changed")))
          
          (name "Update prompts on leaf node")
          (awx.awx.workflow_job_template_node 
            (identifier "leaf")
            (unified_job_template (jinja "{{ jt2_name }}"))
            (lookup_organization (jinja "{{ org_name }}"))
            (workflow (jinja "{{ wfjt_name }}"))
            (execution_environment "")
            (forks "1")
            (instance_groups (list))
            (job_slice_count "1")
            (labels (list))
            (timeout "10"))
          (register "results")
          
          (name "Assert leaf node prompts updated")
          (ansible.builtin.assert 
            (that (list
                "results.changed")))
          
          (name "Remove a node from a workflow that does not exist.")
          (awx.awx.workflow_job_template_node 
            (identifier "root")
            (unified_job_template (jinja "{{ jt1_name }}"))
            (workflow "Does not exist")
            (state "absent"))
          (register "results")
          
          (name "Assert non-existent node was not changed")
          (ansible.builtin.assert 
            (that (list
                "not results.changed")))
          
          (name "Create root node")
          (awx.awx.workflow_job_template_node 
            (identifier "root")
            (unified_job_template (jinja "{{ jt1_name }}"))
            (workflow (jinja "{{ wfjt_name }}")))
          
          (name "Fail if no name is set for approval")
          (awx.awx.workflow_job_template_node 
            (identifier "approval_test")
            (approval_node 
              (description (jinja "{{ approval_node_name }}")))
            (workflow (jinja "{{ wfjt_name }}")))
          (register "no_name_results")
          (failed_when "false")
          (ignore_errors "true")
          
          (name "Assert no name for approval failed")
          (ansible.builtin.assert 
            (that (list
                "no_name_results.msg is search('Approval node name is required to create approval node.')")))
          
          (name "Fail if absent and no identifier set")
          (awx.awx.workflow_job_template_node 
            (identifier "approval_test")
            (approval_node 
              (description (jinja "{{ approval_node_name }}")))
            (workflow (jinja "{{ wfjt_name }}"))
            (state "absent"))
          (register "no_identifier_results")
          (failed_when "false")
          (ignore_errors "true")
          
          (name "Assert no identifier failed")
          (ansible.builtin.assert 
            (that (list
                "no_identifier_results is defined"
                "no_identifier_results is not none")))
          
          (name "Fail if present and no unified job template set")
          (awx.awx.workflow_job_template_node 
            (identifier "approval_test")
            (workflow (jinja "{{ wfjt_name }}")))
          (register "no_unified_results")
          (failed_when "false")
          (ignore_errors "true")
          
          (name "Assert no unified job template defined")
          (ansible.builtin.assert 
            (that (list
                "no_unified_results is defined")))
          
          (name "Assert module failed gracefully")
          (ansible.builtin.assert 
            (that (list
                "no_unified_results is defined")))
          
          (name "Create approval node")
          (awx.awx.workflow_job_template_node 
            (identifier "approval_test")
            (approval_node 
              (name (jinja "{{ approval_node_name }}"))
              (timeout "900"))
            (workflow (jinja "{{ wfjt_name }}")))
          
          (name "Create link for root node")
          (awx.awx.workflow_job_template_node 
            (identifier "root")
            (workflow (jinja "{{ wfjt_name }}"))
            (success_nodes (list
                "approval_test"))
            (always_nodes (list
                "leaf")))
          
          (name "Delete approval node")
          (awx.awx.workflow_job_template_node 
            (identifier "approval_test")
            (approval_node 
              (name (jinja "{{ approval_node_name }}")))
            (state "absent")
            (workflow (jinja "{{ wfjt_name }}")))
          
          (name "Add started notifications to workflow job template")
          (awx.awx.workflow_job_template 
            (name (jinja "{{ wfjt_name }}"))
            (notification_templates_started (list
                (jinja "{{ email_not }}")
                (jinja "{{ webhook_notification }}"))))
          (register "result")
          
          (name "Assert started notifications added")
          (ansible.builtin.assert 
            (that (list
                "result.changed")))
          
          (name "Re Add started notifications to workflow job template")
          (awx.awx.workflow_job_template 
            (name (jinja "{{ wfjt_name }}"))
            (notification_templates_started (list
                (jinja "{{ email_not }}")
                (jinja "{{ webhook_notification }}"))))
          (register "result")
          
          (name "Assert started notifications not re-added")
          (ansible.builtin.assert 
            (that (list
                "not result.changed")))
          
          (name "Add success notifications to workflow job template")
          (awx.awx.workflow_job_template 
            (name (jinja "{{ wfjt_name }}"))
            (notification_templates_success (list
                (jinja "{{ email_not }}")
                (jinja "{{ webhook_notification }}"))))
          (register "result")
          
          (name "Assert success notifications added")
          (ansible.builtin.assert 
            (that (list
                "result.changed")))
          
          (name "Copy a workflow job template")
          (awx.awx.workflow_job_template 
            (name "copy_" (jinja "{{ wfjt_name }}"))
            (copy_from (jinja "{{ wfjt_name }}"))
            (organization "Default"))
          (register "result")
          
          (name "Assert workflow job template copied")
          (ansible.builtin.assert 
            (that (list
                "result.copied")))
          
          (name "Fail Remove \"on start\" webhook notification from copied workflow job template")
          (awx.awx.workflow_job_template 
            (name "copy_" (jinja "{{ wfjt_name }}"))
            (notification_templates_started (list
                (jinja "{{ email_not }}") "123")))
          (register "remove_copied_workflow_node")
          (failed_when "false")
          (ignore_errors "true")
          
          (name "Assert remove of non-existent notification failed")
          (ansible.builtin.assert 
            (that (list
                "not remove_copied_workflow_node.changed"
                "remove_copied_workflow_node.msg is search('returned 0 items')")))
          
          (name "Remove \"on start\" webhook notification from copied workflow job template")
          (awx.awx.workflow_job_template 
            (name "copy_" (jinja "{{ wfjt_name }}"))
            (notification_templates_started (list
                (jinja "{{ email_not }}"))))
          (register "result")
          
          (name "Assert \"on start\" notification removed")
          (ansible.builtin.assert 
            (that (list
                "result.changed")))
          
          (name "Add Survey to Copied workflow job template")
          (awx.awx.workflow_job_template 
            (name "copy_" (jinja "{{ wfjt_name }}"))
            (organization "Default")
            (ask_inventory_on_launch "true")
            (survey_spec 
              (name "Basic Survey")
              (description "Basic Survey")
              (spec (list
                  
                  (question_description "Name")
                  (min "0")
                  (default "")
                  (max "128")
                  (required "true")
                  (choices "")
                  (new_question "true")
                  (variable "basic_name")
                  (question_name "Basic Name")
                  (type "text")
                  
                  (question_description "Choosing yes or no.")
                  (min "0")
                  (default "yes")
                  (max "0")
                  (required "true")
                  (choices "yes
no")
                  (new_question "true")
                  (variable "option_true_false")
                  (question_name "Choose yes or no?")
                  (type "multiplechoice")
                  
                  (question_description "")
                  (min "0")
                  (default "")
                  (max "0")
                  (required "true")
                  (choices "group1
group2
group3")
                  (new_question "true")
                  (variable "target_groups")
                  (question_name "Select Group:")
                  (type "multiselect")
                  
                  (question_name "password")
                  (question_description "")
                  (required "true")
                  (type "password")
                  (variable "password")
                  (min "0")
                  (max "1024")
                  (default "")
                  (choices "")
                  (new_question "true")))))
          (register "result")
          
          (name "Assert survey added to copied workflow")
          (ansible.builtin.assert 
            (that (list
                "result.changed")))
          
          (name "Re add survey to workflow job template expected not changed.")
          (awx.awx.workflow_job_template 
            (name "copy_" (jinja "{{ wfjt_name }}"))
            (organization "Default")
            (survey_spec 
              (name "Basic Survey")
              (description "Basic Survey")
              (spec (list
                  
                  (question_description "Name")
                  (min "0")
                  (default "")
                  (max "128")
                  (required "true")
                  (choices "")
                  (new_question "true")
                  (variable "basic_name")
                  (question_name "Basic Name")
                  (type "text")
                  
                  (question_description "Choosing yes or no.")
                  (min "0")
                  (default "yes")
                  (max "0")
                  (required "true")
                  (choices "yes
no")
                  (new_question "true")
                  (variable "option_true_false")
                  (question_name "Choose yes or no?")
                  (type "multiplechoice")
                  
                  (question_description "")
                  (min "0")
                  (default "")
                  (max "0")
                  (required "true")
                  (choices "group1
group2
group3")
                  (new_question "true")
                  (variable "target_groups")
                  (question_name "Select Group:")
                  (type "multiselect")
                  
                  (question_name "password")
                  (question_description "")
                  (required "true")
                  (type "password")
                  (variable "password")
                  (min "0")
                  (max "1024")
                  (default "")
                  (choices "")
                  (new_question "true")))))
          (register "result")
          
          (name "Assert survey not re-added")
          (ansible.builtin.assert 
            (that (list
                "not result.changed")))
          
          (name "Remove \"on start\" webhook notification from workflow job template")
          (awx.awx.workflow_job_template 
            (name (jinja "{{ wfjt_name }}"))
            (notification_templates_started (list
                (jinja "{{ email_not }}"))))
          (register "result")
          
          (name "Assert \"on start\" webhook notification removed")
          (ansible.builtin.assert 
            (that (list
                "result.changed")))
          
          (name "Delete a workflow job template with an invalid inventory and webook_credential")
          (awx.awx.workflow_job_template 
            (name (jinja "{{ wfjt_name }}"))
            (inventory "Does Not Exist")
            (webhook_credential "Does Not Exist")
            (state "absent"))
          (register "result")
          
          (name "Assert workflow job template with invalid inventory deleted")
          (ansible.builtin.assert 
            (that (list
                "result.changed")))
          
          (name "Check module fails with correct msg")
          (awx.awx.workflow_job_template 
            (name (jinja "{{ wfjt_name }}"))
            (organization "Non_Existing_Organization"))
          (register "result")
          (failed_when "false")
          (ignore_errors "true")
          
          (name "Assert module failed as expected for non-existent org")
          (ansible.builtin.assert 
            (that (list
                "result.msg is search('returned 0 items, expected 1')"
                "result.msg is search('Non_Existing_Organization')")))
          
          (name "Create a workflow job template with workflow nodes in template")
          (awx.awx.workflow_job_template 
            (name (jinja "{{ wfjt_name }}"))
            (inventory "Demo Inventory")
            (extra_vars 
              (foo "bar")
              (another-foo 
                (barz "bar2")))
            (workflow_nodes (list
                
                (identifier "node101")
                (unified_job_template 
                  (id (jinja "{{ project_inv_source_result.id }}")))
                (failure_nodes (list
                    
                    (identifier "node201")))
                
                (identifier "node102")
                (unified_job_template 
                  (organization 
                    (name (jinja "{{ org_name }}")))
                  (name (jinja "{{ demo_project_name_2 }}"))
                  (type "project"))
                (success_nodes (list
                    
                    (identifier "node201")))
                
                (identifier "node201")
                (unified_job_template 
                  (organization 
                    (name "Default"))
                  (name (jinja "{{ jt1_name }}"))
                  (type "job_template"))
                (inventory 
                  (name "Demo Inventory")
                  (organization 
                    (name "Default")))
                (success_nodes (list
                    
                    (identifier "node401")))
                (failure_nodes (list
                    
                    (identifier "node301")))
                (always_nodes (list))
                (credentials (list
                    
                    (name (jinja "{{ scm_cred_name }}"))
                    (organization 
                      (name "Default"))))
                (instance_groups (list
                    
                    (name (jinja "{{ ig1 }}"))))
                (labels (list
                    
                    (name (jinja "{{ lab1 }}"))
                    (organization 
                      (name (jinja "{{ org_name }}")))))
                
                (all_parents_must_converge "false")
                (identifier "node301")
                (unified_job_template 
                  (description "Approval node for example")
                  (timeout "900")
                  (type "workflow_approval")
                  (name (jinja "{{ approval_node_name }}")))
                (success_nodes (list
                    
                    (identifier "node401")))
                
                (identifier "node401")
                (unified_job_template 
                  (name "Cleanup Activity Stream")
                  (type "system_job_template")))))
          (register "result")
          (failed_when "false")
          
          (name "Assert workflow job template with nodes created")
          (ansible.builtin.assert 
            (that (list
                "result is not failed"
                "result is defined")))
          
          (name "Kick off a workflow and wait for it")
          (awx.awx.workflow_launch 
            (workflow_template (jinja "{{ wfjt_name }}")))
          (register "result")
          (failed_when "false")
          
          (name "Assert workflow kicked off and waited")
          (ansible.builtin.assert 
            (that (list
                "not result.failed"
                "'id' in result['job_info']")))
          
          (name "Destroy previous workflow nodes for one that fails")
          (awx.awx.workflow_job_template 
            (name (jinja "{{ wfjt_name }}"))
            (destroy_current_nodes "true")
            (workflow_nodes (list
                
                (identifier "node101")
                (unified_job_template 
                  (organization 
                    (name "Default"))
                  (name (jinja "{{ jt1_name }}"))
                  (type "job_template"))
                (credentials (list))
                (success_nodes (list
                    
                    (identifier "node201")))
                
                (identifier "node201")
                (unified_job_template 
                  (name (jinja "{{ project_inv_source }}"))
                  (inventory 
                    (name (jinja "{{ project_inv }}"))
                    (organization 
                      (name "Default")))
                  (type "inventory_source"))
                
                (identifier "Workflow inception")
                (unified_job_template 
                  (name "copy_" (jinja "{{ wfjt_name }}"))
                  (organization 
                    (name "Default"))
                  (type "workflow_job_template"))
                (credentials (list
                    
                    (name (jinja "{{ scm_cred_name }}"))
                    (organization 
                      (name "Default"))))
                (instance_groups (list
                    
                    (name (jinja "{{ ig1 }}"))
                    
                    (name (jinja "{{ ig2 }}"))))
                (labels (list
                    
                    (name (jinja "{{ label1 }}"))
                    
                    (name (jinja "{{ label2 }}"))
                    (organization 
                      (name (jinja "{{ org_name }}"))))))))
          (register "result")
          
          (name "Delete copied workflow job template")
          (awx.awx.workflow_job_template 
            (name "copy_" (jinja "{{ wfjt_name }}"))
            (state "absent"))
          (register "result")
          
          (name "Assert copied workflow job template deleted")
          (ansible.builtin.assert 
            (that (list
                "result.changed")))
          
          (name "Kick off a workflow and wait for it")
          (awx.awx.workflow_launch 
            (workflow_template (jinja "{{ wfjt_name }}")))
          (register "result")
          (failed_when "false")
          
          (name "Assert the workflow failed as expected")
          (ansible.builtin.assert 
            (that (list
                "result.status == \"failed\""))
            (fail_msg "Workflow did not fail as expected. Status: " (jinja "{{ result.status }}"))
            (success_msg "Workflow failed as expected."))
          
          (name "Create a workflow job template with a GitLab webhook but a GitHub credential")
          (awx.awx.workflow_job_template 
            (name (jinja "{{ webhook_wfjt_name }}"))
            (organization "Default")
            (inventory "Demo Inventory")
            (webhook_service (jinja "{{ 'gitlab' if gitlab_found else omit }}"))
            (webhook_credential (jinja "{{ github_webhook_credential_name if github_found else omit }}")))
          (register "result")
          (failed_when "false")
          
          (name "Assert GitLab webhook with Github cred failed")
          (ansible.builtin.assert 
            (that (list
                "result.failed"
                "result.msg in search('Must match the selected webhook service')")))
          (when "github_found and gitlab_found")
          
          (name "Create a workflow job template with a GitHub webhook and a GitHub credential")
          (awx.awx.workflow_job_template 
            (name (jinja "{{ webhook_wfjt_name }}"))
            (organization "Default")
            (inventory "Demo Inventory")
            (webhook_service (jinja "{{ 'github' if github_found else omit }}"))
            (webhook_credential (jinja "{{ github_webhook_credential_name if github_found else omit }}")))
          (register "result")
          
          (name "Assert Github webhook with Github cred created")
          (ansible.builtin.assert 
            (that (list
                "not result.failed")))))
      (always (list
          
          (name "Cleanup created resources")
          (block (list
              
              (name "Delete the workflow job template")
              (awx.awx.workflow_job_template 
                (name (jinja "{{ item }}"))
                (state "absent"))
              (failed_when "false")
              (loop (list
                  "copy_" (jinja "{{ wfjt_name }}")
                  (jinja "{{ wfjt_name }}")
                  (jinja "{{ webhook_wfjt_name }}")))
              
              (name "Delete the Job Template")
              (awx.awx.job_template 
                (name (jinja "{{ jt1_name }}"))
                (project (jinja "{{ demo_project_name }}"))
                (inventory "Demo Inventory")
                (playbook "hello_world.yml")
                (job_type "run")
                (state "absent"))
              (failed_when "false")
              
              (name "Delete the second Job Template")
              (awx.awx.job_template 
                (name (jinja "{{ jt2_name }}"))
                (project (jinja "{{ demo_project_name }}"))
                (organization "Default")
                (inventory "Demo Inventory")
                (playbook "hello_world.yml")
                (job_type "run")
                (state "absent"))
              (failed_when "false")
              
              (name "Delete the second Job Template")
              (awx.awx.job_template 
                (name (jinja "{{ jt2_name }}"))
                (project (jinja "{{ demo_project_name_2 }}"))
                (organization (jinja "{{ org_name }}"))
                (inventory "Demo Inventory")
                (playbook "hello_world.yml")
                (job_type "run")
                (state "absent"))
              (failed_when "false")
              
              (name "Delete the inventory source")
              (awx.awx.inventory_source 
                (name (jinja "{{ project_inv_source }}"))
                (inventory (jinja "{{ project_inv }}"))
                (source "scm")
                (state "absent"))
              (failed_when "false")
              
              (name "Delete the inventory")
              (awx.awx.inventory 
                (description "Test inventory")
                (organization "Default")
                (name (jinja "{{ project_inv }}"))
                (state "absent"))
              (failed_when "false")
              
              (name "Delete the Demo Project")
              (awx.awx.project 
                (name (jinja "{{ demo_project_name }}"))
                (organization "Default")
                (scm_type "git")
                (scm_url "https://github.com/ansible/ansible-tower-samples.git")
                (scm_credential (jinja "{{ scm_cred_name }}"))
                (state "absent"))
              (failed_when "false")
              
              (name "Delete the 2nd Demo Project")
              (awx.awx.project 
                (name (jinja "{{ demo_project_name_2 }}"))
                (organization (jinja "{{ org_name }}"))
                (scm_type "git")
                (scm_url "https://github.com/ansible/ansible-tower-samples.git")
                (scm_credential (jinja "{{ scm_cred_name }}"))
                (state "absent"))
              (failed_when "false")
              
              (name "Delete the 3rd Demo Project")
              (awx.awx.project 
                (name (jinja "{{ project_inv_source }}"))
                (organization (jinja "{{ org_name }}"))
                (scm_type "git")
                (scm_url "https://github.com/ansible/ansible-tower-samples.git")
                (scm_credential (jinja "{{ scm_cred_name }}"))
                (state "absent"))
              (failed_when "false")
              
              (name "Delete the SCM Credential")
              (awx.awx.credential 
                (name (jinja "{{ scm_cred_name }}"))
                (organization "Default")
                (credential_type "Source Control")
                (state "absent"))
              (failed_when "false")
              
              (name "Delete the GitHub Webhook Credential")
              (awx.awx.credential 
                (name (jinja "{{ github_webhook_credential_name }}"))
                (organization "Default")
                (credential_type "GitHub Personal Access Token")
                (state "absent"))
              (failed_when "false")
              (when "github_found")
              
              (name "Delete email notification")
              (awx.awx.notification_template 
                (name (jinja "{{ email_not }}"))
                (organization "Default")
                (state "absent"))
              (failed_when "false")
              
              (name "Delete webhook notification")
              (awx.awx.notification_template 
                (name (jinja "{{ webhook_notification }}"))
                (organization "Default")
                (state "absent"))
              (failed_when "false")
              
              (name "Delete an execution environment")
              (awx.awx.execution_environment 
                (name (jinja "{{ ee1 }}"))
                (image "junk")
                (state "absent"))
              (failed_when "false")
              
              (name "Delete instance groups")
              (awx.awx.instance_group 
                (name (jinja "{{ item }}"))
                (state "absent"))
              (loop (list
                  (jinja "{{ ig1 }}")
                  (jinja "{{ ig2 }}")))
              (failed_when "false")
              
              (name "Remove the organization")
              (awx.awx.organization 
                (name (jinja "{{ org_name }}"))
                (state "absent"))
              (failed_when "false")
              
              (name "Remove node")
              (awx.awx.host 
                (name (jinja "{{ host1 }}"))
                (inventory "Demo Inventory")
                (state "absent"))
              (failed_when "false"))))))))
