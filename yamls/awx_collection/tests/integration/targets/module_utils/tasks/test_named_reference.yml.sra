(playbook "awx_collection/tests/integration/targets/module_utils/tasks/test_named_reference.yml"
  (tasks
    (task
      (block (list
          
          (name "generate random string for project")
          (set_fact 
            (org_name "AWX-Collection-tests-organization-org-" (jinja "{{ test_id }}"))
            (cred "AWX-Collection-tests-job_template-cred-" (jinja "{{ test_id }}"))
            (inv "AWX-Collection-tests-job_template-inv-" (jinja "{{ test_id }}"))
            (proj "AWX-Collection-tests-job_template-proj-" (jinja "{{ test_id }}"))
            (jt "AWX-Collection-tests-job_template-jt-" (jinja "{{ test_id }}")))
          
          (name "Create a new organization")
          (organization 
            (name (jinja "{{ org_name }}"))
            (galaxy_credentials (list
                "Ansible Galaxy")))
          
          (name "Create an inventory")
          (inventory 
            (name (jinja "{{ inv }}"))
            (organization (jinja "{{ org_name }}")))
          
          (name "Create a Demo Project")
          (project 
            (name (jinja "{{ proj }}"))
            (organization (jinja "{{ org_name }}"))
            (state "present")
            (scm_type "git")
            (scm_url "https://github.com/ansible/ansible-tower-samples.git"))
          
          (name "Create Credential")
          (credential 
            (name (jinja "{{ cred }}"))
            (organization (jinja "{{ org_name }}"))
            (credential_type "Machine"))
          
          (name "Create Job Template")
          (job_template 
            (name (jinja "{{ jt }}"))
            (project (jinja "{{ proj }}") "++" (jinja "{{ org_name }}"))
            (inventory (jinja "{{ inv }}") "++" (jinja "{{ org_name }}"))
            (playbook "hello_world.yml")
            (credentials (list
                (jinja "{{ cred }}") "++Machine+ssh++"))
            (job_type "run")
            (state "present"))))
      (always (list
          
          (name "Delete the Job Template")
          (job_template 
            (name (jinja "{{ jt }}"))
            (state "absent"))
          
          (name "Delete the Demo Project")
          (project 
            (name (jinja "{{ proj }}") "++" (jinja "{{ org_name }}"))
            (state "absent"))
          
          (name "Delete Credential")
          (credential 
            (name (jinja "{{ cred }}") "++Machine+ssh++" (jinja "{{ org_name }}"))
            (credential_type "Machine")
            (state "absent"))
          
          (name "Delete the inventory")
          (inventory 
            (name (jinja "{{ inv }}") "++" (jinja "{{ org_name }}"))
            (organization (jinja "{{ org_name }}"))
            (state "absent"))
          
          (name "Remove the organization")
          (organization 
            (name (jinja "{{ org_name }}"))
            (state "absent")))))))
