(playbook "awx_collection/tests/integration/targets/team/tasks/main.yml"
  (tasks
    (task "Generate a test ID"
      (ansible.builtin.set_fact 
        (test_id (jinja "{{ lookup('password', '/dev/null chars=ascii_letters length=16') }}")))
      (when "test_id is not defined"))
    (task "Generate names"
      (ansible.builtin.set_fact 
        (team_name "AWX-Collection-tests-team-team-" (jinja "{{ test_id }}"))))
    (task "Attempt to add a team to a non-existant Organization"
      (team 
        (name "Test Team")
        (organization "Missing_Organization")
        (state "present"))
      (register "result")
      (ignore_errors "true"))
    (task "Assert a meaningful error was provided for the failed team creation"
      (ansible.builtin.assert 
        (that (list
            "result is failed"
            "'Missing_Organization' in result.msg"))))
    (task "Create a team"
      (team 
        (name (jinja "{{ team_name }}"))
        (organization "Default"))
      (register "result"))
    (task "Assert result changed"
      (ansible.builtin.assert 
        (that (list
            "result.changed"))))
    (task "Create a team with exists"
      (team 
        (name (jinja "{{ team_name }}"))
        (organization "Default")
        (state "exists"))
      (register "result"))
    (task "Assert result did not change"
      (ansible.builtin.assert 
        (that (list
            "not result.changed"))))
    (task "Delete a team"
      (team 
        (name (jinja "{{ team_name }}"))
        (organization "Default")
        (state "absent"))
      (register "result"))
    (task "Assert reesult changed"
      (ansible.builtin.assert 
        (that (list
            "result.changed"))))
    (task "Create a team with exists"
      (team 
        (name (jinja "{{ team_name }}"))
        (organization "Default")
        (state "exists"))
      (register "result"))
    (task "Assert result changed"
      (ansible.builtin.assert 
        (that (list
            "result.changed"))))
    (task "Delete a team"
      (team 
        (name (jinja "{{ team_name }}"))
        (organization "Default")
        (state "absent"))
      (register "result"))
    (task "Assert result changed"
      (ansible.builtin.assert 
        (that (list
            "result.changed"))))
    (task "Check module fails with correct msg"
      (team 
        (name (jinja "{{ team_name }}"))
        (organization "Non_Existing_Org")
        (state "present"))
      (register "result")
      (ignore_errors "true"))
    (task "Assert module failed with expected message"
      (ansible.builtin.assert 
        (that (list
            "result is failed"
            "'returned 0 items, expected 1' in result.msg or 'returned 0 items, expected 1' in result.exception or 'returned 0 items, expected 1' in result.get('msg', '')"))))
    (task "Lookup of the related organization should cause a failure"
      (ansible.builtin.assert 
        (that (list
            "result.failed"
            "not result.changed"
            "'Non_Existing_Org' in result.msg"
            "result.total_results == 0"))))))
