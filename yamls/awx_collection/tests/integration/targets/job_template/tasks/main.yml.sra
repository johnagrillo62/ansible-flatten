(playbook "awx_collection/tests/integration/targets/job_template/tasks/main.yml"
  (tasks
    (task "Generate a random string for test"
      (set_fact 
        (test_id (jinja "{{ lookup('password', '/dev/null chars=ascii_letters length=16') }}")))
      (when "test_id is not defined"))
    (task "generate random string for project"
      (set_fact 
        (org_name "AWX-Collection-tests-organization-org-" (jinja "{{ test_id }}"))
        (cred1 "AWX-Collection-tests-job_template-cred1-" (jinja "{{ test_id }}"))
        (cred2 "AWX-Collection-tests-job_template-cred2-" (jinja "{{ test_id }}"))
        (cred3 "AWX-Collection-tests-job_template-cred3-" (jinja "{{ test_id }}"))
        (inv1 "AWX-Collection-tests-job_template-inv-" (jinja "{{ test_id }}"))
        (proj1 "AWX-Collection-tests-job_template-proj-" (jinja "{{ test_id }}"))
        (jt1 "AWX-Collection-tests-job_template-jt1-" (jinja "{{ test_id }}"))
        (jt2 "AWX-Collection-tests-job_template-jt2-" (jinja "{{ test_id }}"))
        (lab1 "AWX-Collection-tests-job_template-lab1-" (jinja "{{ test_id }}"))
        (email_not "AWX-Collection-tests-job_template-email-not-" (jinja "{{ test_id }}"))
        (webhook_not "AWX-Collection-tests-notification_template-wehbook-not-" (jinja "{{ test_id }}"))
        (group_name1 "AWX-Collection-tests-instance_group-group1-" (jinja "{{ test_id }}"))))
    (task "Create a new organization"
      (organization 
        (name (jinja "{{ org_name }}"))
        (galaxy_credentials (list
            "Ansible Galaxy")))
      (register "result"))
    (task "Create an inventory"
      (inventory 
        (name (jinja "{{ inv1 }}"))
        (organization (jinja "{{ org_name }}"))))
    (task "Create a Demo Project"
      (project 
        (name (jinja "{{ proj1 }}"))
        (organization "Default")
        (state "present")
        (scm_type "git")
        (scm_url "https://github.com/ansible/ansible-tower-samples.git"))
      (register "proj_result"))
    (task "Create Credential1"
      (credential 
        (name (jinja "{{ cred1 }}"))
        (organization "Default")
        (credential_type "Red Hat Ansible Automation Platform"))
      (register "cred1_result"))
    (task "Create Credential2"
      (credential 
        (name (jinja "{{ cred2 }}"))
        (organization "Default")
        (credential_type "Machine")))
    (task "Create Credential3"
      (credential 
        (name (jinja "{{ cred3 }}"))
        (organization "Default")
        (credential_type "Machine")))
    (task "Create Labels"
      (label 
        (name (jinja "{{ lab1 }}"))
        (organization (jinja "{{ item }}")))
      (loop (list
          "Default"
          (jinja "{{ org_name }}"))))
    (task "Create an Instance Group"
      (instance_group 
        (name (jinja "{{ group_name1 }}"))
        (state "present"))
      (register "result"))
    (task
      (assert 
        (that (list
            "result is changed"))))
    (task "Add email notification"
      (notification_template 
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
        (state "present")))
    (task "Add webhook notification"
      (notification_template 
        (name (jinja "{{ webhook_not }}"))
        (organization "Default")
        (notification_type "webhook")
        (notification_configuration 
          (url "http://www.example.com/hook")
          (headers 
            (X-Custom-Header "value123")))
        (state "present"))
      (register "result"))
    (task "Create Job Template 1"
      (job_template 
        (name (jinja "{{ jt1 }}"))
        (project (jinja "{{ proj1 }}"))
        (inventory (jinja "{{ inv1 }}"))
        (playbook "hello_world.yml")
        (credentials (list
            (jinja "{{ cred1 }}")
            (jinja "{{ cred2 }}")))
        (instance_groups (list
            (jinja "{{ group_name1 }}")))
        (job_type "run")
        (state "present"))
      (register "jt1_result"))
    (task
      (assert 
        (that (list
            "jt1_result is changed"))))
    (task "Create Job Template 1 with exists"
      (job_template 
        (name (jinja "{{ jt1 }}"))
        (project (jinja "{{ proj1 }}"))
        (inventory (jinja "{{ inv1 }}"))
        (playbook "hello_world.yml")
        (credentials (list
            (jinja "{{ cred1 }}")
            (jinja "{{ cred2 }}")))
        (instance_groups (list
            (jinja "{{ group_name1 }}")))
        (job_type "run")
        (state "exists"))
      (register "jt1_result"))
    (task
      (assert 
        (that (list
            "jt1_result is not changed"))))
    (task "Delete Job Template 1"
      (job_template 
        (name (jinja "{{ jt1 }}"))
        (project (jinja "{{ proj1 }}"))
        (inventory (jinja "{{ inv1 }}"))
        (playbook "hello_world.yml")
        (credentials (list
            (jinja "{{ cred1 }}")
            (jinja "{{ cred2 }}")))
        (instance_groups (list
            (jinja "{{ group_name1 }}")))
        (job_type "run")
        (state "absent"))
      (register "jt1_result"))
    (task
      (assert 
        (that (list
            "jt1_result is changed"))))
    (task "Create Job Template 1 with exists"
      (job_template 
        (name (jinja "{{ jt1 }}"))
        (project (jinja "{{ proj1 }}"))
        (inventory (jinja "{{ inv1 }}"))
        (playbook "hello_world.yml")
        (credentials (list
            (jinja "{{ cred1 }}")
            (jinja "{{ cred2 }}")))
        (instance_groups (list
            (jinja "{{ group_name1 }}")))
        (job_type "run")
        (state "exists"))
      (register "jt1_result"))
    (task
      (assert 
        (that (list
            "jt1_result is changed"))))
    (task "Add a credential to this JT"
      (job_template 
        (name (jinja "{{ jt1 }}"))
        (project (jinja "{{ proj_result.id }}"))
        (playbook "hello_world.yml")
        (credentials (list
            (jinja "{{ cred1_result.id }}"))))
      (register "result"))
    (task
      (assert 
        (that (list
            "result is changed"))))
    (task "Try to add the same credential to this JT"
      (job_template 
        (name (jinja "{{ jt1_result.id }}"))
        (project (jinja "{{ proj1 }}"))
        (playbook "hello_world.yml")
        (credentials (list
            (jinja "{{ cred1 }}"))))
      (register "result"))
    (task
      (assert 
        (that (list
            "result is not changed"))))
    (task "Add another credential to this JT"
      (job_template 
        (name (jinja "{{ jt1 }}"))
        (project (jinja "{{ proj1 }}"))
        (playbook "hello_world.yml")
        (credentials (list
            (jinja "{{ cred1 }}")
            (jinja "{{ cred2 }}"))))
      (register "result"))
    (task
      (assert 
        (that (list
            "result is changed"))))
    (task "Remove a credential for this JT"
      (job_template 
        (name (jinja "{{ jt1 }}"))
        (project (jinja "{{ proj1 }}"))
        (playbook "hello_world.yml")
        (credentials (list
            (jinja "{{ cred1 }}"))))
      (register "result"))
    (task
      (assert 
        (that (list
            "result is changed"))))
    (task "Remove all credentials from this JT"
      (job_template 
        (name (jinja "{{ jt1 }}"))
        (project (jinja "{{ proj1 }}"))
        (playbook "hello_world.yml")
        (credentials (list)))
      (register "result"))
    (task
      (assert 
        (that (list
            "result is changed"))))
    (task "Copy Job Template"
      (job_template 
        (name "copy_" (jinja "{{ jt1 }}"))
        (copy_from (jinja "{{ jt1 }}"))
        (state "present")))
    (task "Delete copied Job Template"
      (job_template 
        (name "copy_" (jinja "{{ jt1 }}"))
        (job_type "run")
        (state "absent"))
      (register "result"))
    (task "Delete Job Template 1"
      (job_template 
        (name (jinja "{{ jt1 }}"))
        (playbook "hello_world.yml")
        (job_type "run")
        (project "Does Not Exist")
        (inventory "Does Not Exist")
        (webhook_credential "Does Not Exist")
        (state "absent"))
      (register "result"))
    (task
      (assert 
        (that (list
            "result is changed"))))
    (task "Create Job Template 2"
      (job_template 
        (name (jinja "{{ jt2 }}"))
        (organization "Default")
        (project (jinja "{{ proj1 }}"))
        (inventory (jinja "{{ inv1 }}"))
        (playbook "hello_world.yml")
        (credential (jinja "{{ cred3 }}"))
        (job_type "run")
        (labels (list
            (jinja "{{ lab1 }}")))
        (state "present"))
      (register "result"))
    (task
      (assert 
        (that (list
            "result is changed"))))
    (task "add bad label to Job Template 2"
      (job_template 
        (name (jinja "{{ jt2 }}"))
        (organization "Default")
        (project (jinja "{{ proj1 }}"))
        (inventory (jinja "{{ inv1 }}"))
        (playbook "hello_world.yml")
        (credential (jinja "{{ cred3 }}"))
        (job_type "run")
        (labels (list
            "label_bad"))
        (state "present"))
      (register "bad_label_results")
      (ignore_errors "yes"))
    (task
      (assert 
        (that (list
            "bad_label_results is defined"
            "not (bad_label_results.failed | default(false)) or ('msg' in bad_label_results)"))))
    (task "Add survey to Job Template 2"
      (job_template 
        (name (jinja "{{ jt2 }}"))
        (survey_enabled "true")
        (survey_spec 
          (name "")
          (description "")
          (spec (list
              
              (question_name "Q1")
              (question_description "The first question")
              (required "true")
              (type "text")
              (variable "q1")
              (min "5")
              (max "15")
              (default "hello")))))
      (register "result"))
    (task
      (assert 
        (that (list
            "result is changed"))))
    (task "Re Add survey to Job Template 2"
      (job_template 
        (name (jinja "{{ jt2 }}"))
        (survey_enabled "true")
        (survey_spec 
          (name "")
          (description "")
          (spec (list
              
              (question_name "Q1")
              (question_description "The first question")
              (required "true")
              (type "text")
              (variable "q1")
              (min "5")
              (max "15")
              (default "hello")))))
      (register "result"))
    (task
      (assert 
        (that (list
            "result is not changed"))))
    (task "Add question to survey to Job Template 2"
      (job_template 
        (name (jinja "{{ jt2 }}"))
        (survey_enabled "true")
        (survey_spec 
          (name "")
          (description "")
          (spec (list
              
              (question_name "Q1")
              (question_description "The first question")
              (required "true")
              (type "text")
              (variable "q1")
              (min "5")
              (max "15")
              (default "hello")
              (choices "")
              
              (question_name "Q2")
              (type "text")
              (variable "q2")
              (required "false")))))
      (register "result"))
    (task
      (assert 
        (that (list
            "result is changed"))))
    (task "Remove survey from Job Template 2"
      (job_template 
        (name (jinja "{{ jt2 }}"))
        (survey_enabled "false")
        (survey_spec ))
      (register "result"))
    (task
      (assert 
        (that (list
            "result is changed"))))
    (task "Add started notifications to Job Template 2"
      (job_template 
        (name (jinja "{{ jt2 }}"))
        (notification_templates_started (list
            (jinja "{{ email_not }}")
            (jinja "{{ webhook_not }}"))))
      (register "result"))
    (task
      (assert 
        (that (list
            "result is changed"))))
    (task "Re Add started notifications to Job Template 2"
      (job_template 
        (name (jinja "{{ jt2 }}"))
        (notification_templates_started (list
            (jinja "{{ email_not }}")
            (jinja "{{ webhook_not }}"))))
      (register "result"))
    (task
      (assert 
        (that (list
            "result is not changed"))))
    (task "Add success notifications to Job Template 2"
      (job_template 
        (name (jinja "{{ jt2 }}"))
        (notification_templates_success (list
            (jinja "{{ email_not }}")
            (jinja "{{ webhook_not }}"))))
      (register "result"))
    (task
      (assert 
        (that (list
            "result is changed"))))
    (task "Remove \"on start\" webhook notification from Job Template 2"
      (job_template 
        (name (jinja "{{ jt2 }}"))
        (notification_templates_started (list
            (jinja "{{ email_not }}"))))
      (register "result"))
    (task
      (assert 
        (that (list
            "result is changed"))))
    (task "Delete Job Template 2"
      (job_template 
        (name (jinja "{{ jt2 }}"))
        (project (jinja "{{ proj1 }}"))
        (inventory (jinja "{{ inv1 }}"))
        (playbook "hello_world.yml")
        (credential (jinja "{{ cred3 }}"))
        (job_type "run")
        (state "absent"))
      (register "del_res")
      (until "del_res is succeeded")
      (retries "5")
      (delay "3"))
    (task
      (assert 
        (that (list
            "del_res is changed"))))
    (task "Delete the Demo Project"
      (project 
        (name (jinja "{{ proj1 }}"))
        (organization "Default")
        (state "absent")
        (scm_type "git")
        (scm_url "https://github.com/ansible/ansible-tower-samples.git")))
    (task "Delete Credential1"
      (credential 
        (name (jinja "{{ cred1 }}"))
        (organization "Default")
        (credential_type "Red Hat Ansible Automation Platform")
        (state "absent")))
    (task "Delete Credential2"
      (credential 
        (name (jinja "{{ cred2 }}"))
        (organization "Default")
        (credential_type "Machine")
        (state "absent")))
    (task "Delete Credential3"
      (credential 
        (name (jinja "{{ cred3 }}"))
        (organization "Default")
        (credential_type "Machine")
        (state "absent")))
    (task "Delete email notification"
      (notification_template 
        (name (jinja "{{ email_not }}"))
        (organization "Default")
        (state "absent")))
    (task "Delete the instance groups"
      (instance_group 
        (name (jinja "{{ group_name1 }}"))
        (state "absent")))
    (task "Delete webhook notification"
      (notification_template 
        (name (jinja "{{ webhook_not }}"))
        (organization "Default")
        (state "absent")))
    (task "Delete an inventory"
      (inventory 
        (name (jinja "{{ inv1 }}"))
        (organization (jinja "{{ org_name }}"))
        (state "absent")))
    (task "Remove the organization"
      (organization 
        (name (jinja "{{ org_name }}"))
        (state "absent")))))
