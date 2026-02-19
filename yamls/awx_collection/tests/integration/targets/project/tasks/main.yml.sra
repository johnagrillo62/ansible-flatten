(playbook "awx_collection/tests/integration/targets/project/tasks/main.yml"
  (tasks
    (task "Generate a test ID"
      (set_fact 
        (test_id (jinja "{{ lookup('password', '/dev/null chars=ascii_letters length=16') }}")))
      (when "test_id is not defined"))
    (task "Generate names"
      (set_fact 
        (project_name1 "AWX-Collection-tests-project-project1-" (jinja "{{ test_id }}"))
        (project_name2 "AWX-Collection-tests-project-project2-" (jinja "{{ test_id }}"))
        (project_name3 "AWX-Collection-tests-project-project3-" (jinja "{{ test_id }}"))
        (jt1 "AWX-Collection-tests-project-jt1-" (jinja "{{ test_id }}"))
        (scm_cred_name "AWX-Collection-tests-project-scm-cred-" (jinja "{{ test_id }}"))
        (org_name "AWX-Collection-tests-project-org-" (jinja "{{ test_id }}"))
        (cred_name "AWX-Collection-tests-project-cred-" (jinja "{{ test_id }}"))))
    (task
      (block (list
          
          (name "Create an SCM Credential")
          (credential 
            (name (jinja "{{ scm_cred_name }}"))
            (organization "Default")
            (credential_type "Source Control"))
          (register "result")
          
          (assert 
            (that (list
                "result is changed")))
          
          (name "Create a git project without credentials and wait")
          (project 
            (name (jinja "{{ project_name1 }}"))
            (organization "Default")
            (scm_type "git")
            (scm_url "https://github.com/ansible/ansible-tower-samples")
            (wait "true"))
          (register "result")
          
          (assert 
            (that (list
                "result is changed")))
          
          (name "Create a git project without credentials and wait with exists")
          (project 
            (name (jinja "{{ project_name1 }}"))
            (organization "Default")
            (scm_type "git")
            (scm_url "https://github.com/ansible/ansible-tower-samples")
            (wait "true")
            (state "exists"))
          (register "result")
          
          (assert 
            (that (list
                "result is not changed")))
          
          (name "Create a git project and wait with short request timeout.")
          (project 
            (name (jinja "{{ project_name1 }}"))
            (organization "Default")
            (scm_type "git")
            (scm_url "https://github.com/ansible/ansible-tower-samples")
            (wait "true")
            (state "exists")
            (request_timeout ".001"))
          (register "result")
          (ignore_errors "yes")
          
          (assert 
            (that (list
                "result is failed"
                "'timed out' in result.msg")))
          
          (name "Delete a git project without credentials and wait")
          (project 
            (name (jinja "{{ project_name1 }}"))
            (organization "Default")
            (scm_type "git")
            (scm_url "https://github.com/ansible/ansible-tower-samples")
            (wait "true")
            (state "absent"))
          (register "result")
          
          (assert 
            (that (list
                "result is changed")))
          
          (name "Create a git project without credentials and wait with exists")
          (project 
            (name (jinja "{{ project_name1 }}"))
            (organization "Default")
            (scm_type "git")
            (scm_url "https://github.com/ansible/ansible-tower-samples")
            (wait "true")
            (state "exists"))
          (register "result")
          
          (assert 
            (that (list
                "result is changed")))
          
          (name "Recreate the project to validate not changed")
          (project 
            (name (jinja "{{ project_name1 }}"))
            (organization "Default")
            (scm_type "git")
            (scm_url "https://github.com/ansible/ansible-tower-samples")
            (wait "false"))
          (register "result")
          (ignore_errors "yes")
          
          (assert 
            (that (list
                "result is not changed")))
          
          (name "Create organizations")
          (organization 
            (name (jinja "{{ org_name }}")))
          (register "result")
          
          (assert 
            (that (list
                "result is changed")))
          
          (name "Create credential")
          (credential 
            (credential_type "Source Control")
            (name (jinja "{{ cred_name }}"))
            (organization (jinja "{{ org_name }}")))
          (register "result")
          
          (assert 
            (that (list
                "result is changed")))
          
          (name "Create a new test project in check_mode")
          (project 
            (name (jinja "{{ project_name2 }}"))
            (organization (jinja "{{ org_name }}"))
            (scm_type "git")
            (scm_url "https://github.com/ansible/ansible-tower-samples")
            (scm_credential (jinja "{{ cred_name }}")))
          (check_mode "true")
          
          (name "Copy project from " (jinja "{{ project_name1 }}"))
          (project 
            (name (jinja "{{ project_name2 }}"))
            (copy_from (jinja "{{ project_name1 }}"))
            (organization (jinja "{{ org_name }}"))
            (scm_type "git")
            (scm_credential (jinja "{{ cred_name }}"))
            (state "present"))
          (register "result")
          
          (assert 
            (that (list
                "result.copied")))
          
          (name "Check module fails with correct msg when given non-existing org as param")
          (project 
            (name (jinja "{{ project_name2 }}"))
            (organization "Non_Existing_Org")
            (scm_type "git")
            (scm_url "https://github.com/ansible/ansible-tower-samples")
            (scm_credential (jinja "{{ cred_name }}")))
          (register "result")
          (ignore_errors "yes")
          
          (assert 
            (that (list
                "result is failed"
                "result is not changed"
                "'Non_Existing_Org' in result.msg"
                "result.total_results == 0")))
          
          (name "Check module fails with correct msg when given non-existing credential as param")
          (project 
            (name (jinja "{{ project_name2 }}"))
            (organization (jinja "{{ org_name }}"))
            (scm_type "git")
            (scm_url "https://github.com/ansible/ansible-tower-samples")
            (scm_credential "Non_Existing_Credential"))
          (register "result")
          (ignore_errors "yes")
          
          (assert 
            (that (list
                "result is failed"
                "result is not changed"
                "'Non_Existing_Credential' in result.msg"
                "result.total_results == 0")))
          
          (name "Create a git project using a branch and allowing branch override")
          (project 
            (name (jinja "{{ project_name3 }}"))
            (organization "Default")
            (scm_type "git")
            (scm_branch "empty_branch")
            (scm_url "https://github.com/ansible/test-playbooks")
            (allow_override "true"))
          (register "result")
          
          (assert 
            (that (list
                "result is changed")))
          
          (name "Update the project and wait. Verify not changed as no change made to repo and refspec not changed")
          (project 
            (name (jinja "{{ project_name3 }}"))
            (organization "Default")
            (scm_type "git")
            (scm_branch "empty_branch")
            (scm_url "https://github.com/ansible/test-playbooks")
            (allow_override "true")
            (wait "true")
            (update_project "true"))
          (register "result")
          
          (assert 
            (that (list
                "result is not changed")))
          
          (name "Create a job template that overrides the project scm_branch")
          (job_template 
            (name (jinja "{{ jt1 }}"))
            (project (jinja "{{ project_name3 }}"))
            (inventory "Demo Inventory")
            (scm_branch "master")
            (playbook "debug.yml"))
          
          (name "Launch \"" (jinja "{{ jt1 }}") "\"")
          (job_launch 
            (job_template (jinja "{{ jt1 }}")))
          (register "result")
          
          (assert 
            (that (list
                "result is changed")))
          
          (name "wait for job " (jinja "{{ result.id }}"))
          (job_wait 
            (job_id (jinja "{{ result.id }}")))
          (register "job")
          
          (assert 
            (that (list
                "job is successful")))
          
          (name "Rename an inventory")
          (project 
            (name (jinja "{{ project_name3 }}"))
            (new_name (jinja "{{ project_name3 }}") "a")
            (organization "Default")
            (state "present"))
          (register "result")
          
          (assert 
            (that (list
                "result.changed")))
          
          (name "Set project to remote archive and test that it updates correctly.")
          (project 
            (name (jinja "{{ project_name3 }}"))
            (organization "Default")
            (scm_type "archive")
            (scm_url "https://github.com/ansible/test-playbooks/archive/refs/tags/1.0.0.tar.gz")
            (wait "true")
            (update_project "true"))
          (register "result")
          
          (assert 
            (that (list
                "result is changed")))))
      (always (list
          
          (name "Delete the test job_template")
          (job_template 
            (name (jinja "{{ jt1 }}"))
            (project (jinja "{{ project_name3 }}"))
            (inventory "Demo Inventory")
            (state "absent"))
          
          (name "Delete the test project 3")
          (project 
            (name (jinja "{{ project_name3 }}"))
            (organization "Default")
            (state "absent"))
          
          (name "Delete the test project 3a")
          (project 
            (name (jinja "{{ project_name3 }}") "a")
            (organization "Default")
            (state "absent"))
          
          (name "Delete the test project 2")
          (project 
            (name (jinja "{{ project_name2 }}"))
            (organization (jinja "{{ org_name }}"))
            (state "absent"))
          
          (name "Delete the SCM Credential")
          (credential 
            (name (jinja "{{ scm_cred_name }}"))
            (organization "Default")
            (credential_type "Source Control")
            (state "absent"))
          (register "result")
          
          (assert 
            (that (list
                "result is changed")))
          
          (name "Delete the test project 1")
          (project 
            (name (jinja "{{ project_name1 }}"))
            (organization "Default")
            (state "absent"))
          (register "result")
          
          (assert 
            (that (list
                "result is changed")))
          
          (name "Delete credential")
          (credential 
            (credential_type "Source Control")
            (name (jinja "{{ cred_name }}"))
            (organization (jinja "{{ org_name }}"))
            (state "absent"))
          (register "result")
          
          (assert 
            (that (list
                "result is changed")))
          
          (name "Delete the organization")
          (organization 
            (name (jinja "{{ org_name }}"))
            (state "absent"))
          (register "result")
          
          (assert 
            (that (list
                "result is changed"))))))))
