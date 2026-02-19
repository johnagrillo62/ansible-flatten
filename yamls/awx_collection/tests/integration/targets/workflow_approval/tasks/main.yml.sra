(playbook "awx_collection/tests/integration/targets/workflow_approval/tasks/main.yml"
  (tasks
    (task "Generate a random string for names"
      (ansible.builtin.set_fact 
        (test_id (jinja "{{ lookup('password', '/dev/null chars=ascii_letters length=16') }}")))
      (when "test_id is not defined"))
    (task "Generate random names for test objects"
      (ansible.builtin.set_fact 
        (org_name (jinja "{{ test_prefix }}") "-org-" (jinja "{{ test_id }}"))
        (approval_node_name (jinja "{{ test_prefix }}") "-node-" (jinja "{{ test_id }}"))
        (wfjt_name (jinja "{{ test_prefix }}") "-wfjt-" (jinja "{{ test_id }}")))
      (vars 
        (test_prefix "AWX-Collection-tests-workflow_approval")))
    (task "Task block"
      (block (list
          
          (name "Create a new organization for test isolation")
          (organization 
            (name (jinja "{{ org_name }}")))
          
          (name "Create a workflow job template")
          (workflow_job_template 
            (name (jinja "{{ wfjt_name }}"))
            (organization (jinja "{{ org_name }}")))
          
          (name "Create approval node")
          (workflow_job_template_node 
            (identifier "approval_test")
            (approval_node 
              (name (jinja "{{ approval_node_name }}"))
              (timeout "900"))
            (workflow (jinja "{{ wfjt_name }}")))
          
          (name "Launch the workflow")
          (workflow_launch 
            (workflow_template (jinja "{{ wfjt_name }}"))
            (wait "false"))
          (register "workflow_job")
          
          (name "Wait for approval node to activate and approve")
          (workflow_approval 
            (workflow_job_id (jinja "{{ workflow_job.id }}"))
            (name (jinja "{{ approval_node_name }}"))
            (interval "10")
            (timeout "20")
            (action "approve"))
          (register "result")
          
          (name "Assert result changed and did not fail")
          (ansible.builtin.assert 
            (that (list
                "result.changed"
                "not (result.failed)")))))
      (always (list
          
          (name "Delete the workflow job template")
          (workflow_job_template 
            (name (jinja "{{ wfjt_name }}"))
            (state "absent"))
          (register "delete_result")
          (failed_when "delete_result.failed and \"'not found' not in delete_result.msg\""))))))
