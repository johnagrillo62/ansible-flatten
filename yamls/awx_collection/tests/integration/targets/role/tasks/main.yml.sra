(playbook "awx_collection/tests/integration/targets/role/tasks/main.yml"
  (tasks
    (task "Generate a test id"
      (ansible.builtin.set_fact 
        (test_id (jinja "{{ lookup('password', '/dev/null chars=ascii_letters length=16') }}")))
      (when "test_id is not defined"))
    (task "Generate names"
      (ansible.builtin.set_fact 
        (username "AWX-Collection-tests-role-user-" (jinja "{{ test_id }}"))
        (project_name "AWX-Collection-tests-role-project-1-" (jinja "{{ test_id }}"))
        (jt1 "AWX-Collection-tests-role-jt1-" (jinja "{{ test_id }}"))
        (jt2 "AWX-Collection-tests-role-jt2-" (jinja "{{ test_id }}"))
        (wfjt_name "AWX-Collection-tests-role-project-wfjt-" (jinja "{{ test_id }}"))
        (team_name "AWX-Collection-tests-team-team-" (jinja "{{ test_id }}"))
        (team2_name "AWX-Collection-tests-team-team-" (jinja "{{ test_id }}") "2")
        (org2_name "AWX-Collection-tests-organization-" (jinja "{{ test_id }}") "2")))
    (task "Main block for user creation"
      (block (list
          
          (name "Create a user with a valid sanitized name")
          (awx.awx.user 
            (username (jinja "{{ username }}"))
            (password (jinja "{{ 65535 | random | to_uuid }}"))
            (state "present"))
          (register "result")
          
          (name "Assert result changed")
          (ansible.builtin.assert 
            (that (list
                "result.changed")))
          
          (name "Create a 2nd User")
          (awx.awx.user 
            (username (jinja "{{ username }}") "2")
            (password (jinja "{{ 65535 | random | to_uuid }}"))
            (state "present"))
          (register "result")
          
          (name "Assert result changed")
          (ansible.builtin.assert 
            (that (list
                "result.changed")))
          
          (name "Create teams")
          (team 
            (name (jinja "{{ item }}"))
            (organization "Default"))
          (register "result")
          (loop (list
              (jinja "{{ team_name }}")
              (jinja "{{ team2_name }}")))
          
          (name "Assert result changed")
          (ansible.builtin.assert 
            (that (list
                "result.changed")))
          
          (name "Create a project")
          (project 
            (name (jinja "{{ project_name }}"))
            (organization "Default")
            (scm_type "git")
            (scm_url "https://github.com/ansible/test-playbooks")
            (wait "true"))
          (register "project_info")
          
          (name "Assert project_info is changed")
          (ansible.builtin.assert 
            (that (list
                "project_info is changed")))
          
          (name "Create job templates")
          (job_template 
            (name (jinja "{{ item }}"))
            (project (jinja "{{ project_name }}"))
            (inventory "Demo Inventory")
            (playbook "become.yml"))
          (with_items (list
              "jt1"
              "jt2"))
          (register "result")
          
          (name "Assert result changed")
          (ansible.builtin.assert 
            (that (list
                "result.changed")))
          
          (name "Add Joe and teams to the update role of the default Project with lookup Organization")
          (role 
            (user (jinja "{{ username }}"))
            (users (list
                (jinja "{{ username }}") "2"))
            (teams (list
                (jinja "{{ team_name }}")
                (jinja "{{ team2_name }}")))
            (role "update")
            (lookup_organization "Default")
            (project "Demo Project")
            (state (jinja "{{ item }}")))
          (register "result")
          (with_items (list
              "present"
              "absent"))
          
          (name "Assert result changed")
          (ansible.builtin.assert 
            (that (list
                "result.changed")))
          
          (name "Add Joe to the new project by ID")
          (role 
            (user (jinja "{{ username }}"))
            (users (list
                (jinja "{{ username }}") "2"))
            (teams (list
                (jinja "{{ team_name }}")
                (jinja "{{ team2_name }}")))
            (role "update")
            (project (jinja "{{ project_info['id'] }}"))
            (state (jinja "{{ item }}")))
          (register "result")
          (with_items (list
              "present"
              "absent"))
          
          (name "Assert result changed")
          (ansible.builtin.assert 
            (that (list
                "result.changed")))
          
          (name "Add Joe as execution admin to Default Org.")
          (role 
            (user (jinja "{{ username }}"))
            (users (list
                (jinja "{{ username }}") "2"))
            (role "execution_environment_admin")
            (organizations "Default")
            (state (jinja "{{ item }}")))
          (register "result")
          (with_items (list
              "present"
              "absent"))
          
          (name "Assert result changed")
          (ansible.builtin.assert 
            (that (list
                "result.changed")))
          
          (name "Create a workflow")
          (workflow_job_template 
            (name "test-role-workflow")
            (organization "Default")
            (state "present"))
          
          (name "Add Joe to workflow execute role")
          (role 
            (user (jinja "{{ username }}"))
            (users (list
                (jinja "{{ username }}") "2"))
            (role "execute")
            (workflow "test-role-workflow")
            (job_templates (list
                "jt1"
                "jt2"))
            (state "present"))
          (register "result")
          
          (name "Assert result changed")
          (ansible.builtin.assert 
            (that (list
                "result.changed")))
          
          (name "Add Joe to nonexistent job template execute role")
          (awx.awx.role 
            (user (jinja "{{ username }}"))
            (role "execute")
            (job_template "non existant temp")
            (state "present"))
          (register "results")
          (ignore_errors "true")
          
          (name "Assert that adding a role to a non-existent template failed correctly")
          (ansible.builtin.assert 
            (that (list
                "results.failed"
                "'missing items' in results.msg")))
          
          (name "Add Joe to workflow execute role, no-op")
          (role 
            (user (jinja "{{ username }}"))
            (users (list
                (jinja "{{ username }}") "2"))
            (role "execute")
            (workflow "test-role-workflow")
            (state "present"))
          (register "result")
          
          (name "Assert result did not change")
          (ansible.builtin.assert 
            (that (list
                "result is not changed")))
          
          (name "Add Joe to workflow approve role")
          (role 
            (users (list
                (jinja "{{ username }}") "2"))
            (role "approval")
            (workflow "test-role-workflow")
            (state "present"))
          (register "result")
          
          (name "Assert result changed")
          (ansible.builtin.assert 
            (that (list
                "result.changed")))
          
          (name "Create a 2nd organization")
          (organization 
            (name (jinja "{{ org2_name }}")))
          
          (name "Create a project in 2nd Organization")
          (project 
            (name (jinja "{{ project_name }}"))
            (organization (jinja "{{ org2_name }}"))
            (scm_type "git")
            (scm_url "https://github.com/ansible/test-playbooks")
            (wait "true"))
          (register "project_info")
          
          (name "Add Joe and teams to the update role of the default Project with lookup from the 2nd Organization")
          (role 
            (user (jinja "{{ username }}"))
            (users (list
                (jinja "{{ username }}") "2"))
            (teams (list
                (jinja "{{ team_name }}")
                (jinja "{{ team2_name }}")))
            (role "update")
            (lookup_organization (jinja "{{ org2_name }}"))
            (project (jinja "{{ project_name }}"))
            (state (jinja "{{ item }}")))
          (register "result")
          (with_items (list
              "present"
              "absent"))
          
          (name "Assert result changed")
          (ansible.builtin.assert 
            (that (list
                "result.changed")))))
      (always (list
          
          (name "Delete a User")
          (ansible.builtin.user 
            (name (jinja "{{ username }}"))
            (state "absent"))
          (register "result")
          
          (name "Delete a 2nd User")
          (ansible.builtin.user 
            (name (jinja "{{ username }}") "2")
            (state "absent"))
          (register "result")
          
          (name "Delete teams")
          (team 
            (name (jinja "{{ item }}"))
            (organization "Default")
            (state "absent"))
          (register "result")
          (loop (list
              (jinja "{{ team_name }}")
              (jinja "{{ team2_name }}")))
          
          (name "Delete job templates")
          (job_template 
            (name (jinja "{{ item }}"))
            (project (jinja "{{ project_name }}"))
            (inventory "Demo Inventory")
            (playbook "debug.yml")
            (state "absent"))
          (with_items (list
              "jt1"
              "jt2"))
          
          (name "Delete the project")
          (project 
            (name (jinja "{{ project_name }}"))
            (organization "Default")
            (state "absent"))
          (register "del_res")
          (until "del_res is succeeded")
          (retries "5")
          (delay "3")
          
          (name "Delete the 2nd organization")
          (organization 
            (name (jinja "{{ org2_name }}"))
            (state "absent")))))))
