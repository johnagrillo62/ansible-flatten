(playbook "awx_collection/tests/integration/targets/job_launch/tasks/main.yml"
  (tasks
    (task "Generate a test ID"
      (set_fact 
        (test_id (jinja "{{ lookup('password', '/dev/null chars=ascii_letters length=16') }}")))
      (when "test_id is not defined"))
    (task "Generate names"
      (set_fact 
        (jt_name1 "AWX-Collection-tests-job_launch-jt1-" (jinja "{{ test_id }}"))
        (jt_name2 "AWX-Collection-tests-job_launch-jt2-" (jinja "{{ test_id }}"))
        (proj_name "AWX-Collection-tests-job_launch-project-" (jinja "{{ test_id }}"))))
    (task "Launch a Job Template"
      (job_launch 
        (job_template "Demo Job Template"))
      (register "result"))
    (task
      (assert 
        (that (list
            "result is changed"
            "result.status == 'pending'"))))
    (task "Wait for a job template to complete"
      (job_wait 
        (job_id (jinja "{{ result.id }}"))
        (interval "10")
        (timeout "120"))
      (register "result"))
    (task
      (assert 
        (that (list
            "result is not changed"
            "result.status == 'successful'"))))
    (task "Check module fails with correct msg"
      (job_launch 
        (job_template "Non_Existing_Job_Template")
        (inventory "Demo Inventory"))
      (register "result")
      (ignore_errors "yes"))
    (task
      (assert 
        (that (list
            "result is failed"
            "result is not changed"
            "'Non_Existing_Job_Template' in result.msg"))))
    (task "Create a Job Template for testing prompt on launch"
      (job_template 
        (name (jinja "{{ jt_name1 }}"))
        (project "Demo Project")
        (playbook "hello_world.yml")
        (job_type "run")
        (ask_credential "true")
        (ask_inventory "true")
        (ask_tags_on_launch "true")
        (ask_skip_tags_on_launch "true")
        (state "present"))
      (register "result"))
    (task "Launch job template with inventory and credential for prompt on launch"
      (job_launch 
        (job_template (jinja "{{ jt_name1 }}"))
        (inventory "Demo Inventory")
        (credential "Demo Credential")
        (tags (list
            "sometimes"))
        (skip_tags (list
            "always")))
      (register "result"))
    (task
      (assert 
        (that (list
            "result is changed"
            "result.status == 'pending'"))))
    (task "Create a project for testing extra_vars"
      (project 
        (name (jinja "{{ proj_name }}"))
        (organization "Default")
        (scm_type "git")
        (scm_url "https://github.com/ansible/test-playbooks")))
    (task "Create the job template with survey"
      (job_template 
        (name (jinja "{{ jt_name2 }}"))
        (project (jinja "{{ proj_name }}"))
        (playbook "debug.yml")
        (job_type "run")
        (state "present")
        (inventory "Demo Inventory")
        (survey_enabled "true")
        (ask_variables_on_launch "false")
        (survey_spec 
          (name "")
          (description "")
          (spec (list
              
              (question_name "Basic Name")
              (question_description "Name")
              (required "true")
              (type "text")
              (variable "basic_name")
              (min "0")
              (max "1024")
              (default "")
              (choices "")
              (new_question "true")
              
              (question_name "Choose yes or no?")
              (question_description "Choosing yes or no.")
              (required "false")
              (type "multiplechoice")
              (variable "option_true_false")
              (min null)
              (max null)
              (default "yes")
              (choices "yes
no")
              (new_question "true"))))))
    (task "Kick off a job template with survey"
      (job_launch 
        (job_template (jinja "{{ jt_name2 }}"))
        (extra_vars 
          (basic_name "My First Variable")
          (option_true_false "no")))
      (ignore_errors "yes")
      (register "result"))
    (task
      (assert 
        (that (list
            "result is not failed"))))
    (task "Prompt the job templates extra_vars on launch"
      (job_template 
        (name (jinja "{{ jt_name2 }}"))
        (state "present")
        (ask_variables_on_launch "true")))
    (task "Kick off a job template with extra_vars"
      (job_launch 
        (job_template (jinja "{{ jt_name2 }}"))
        (extra_vars 
          (basic_name "My First Variable")
          (var1 "My First Variable")
          (var2 "My Second Variable")))
      (ignore_errors "yes")
      (register "result"))
    (task
      (assert 
        (that (list
            "result is not failed"))))
    (task "Create a Job Template for testing extra_vars"
      (job_template 
        (name (jinja "{{ jt_name2 }}"))
        (project (jinja "{{ proj_name }}"))
        (playbook "debug.yml")
        (job_type "run")
        (survey_enabled "false")
        (state "present")
        (inventory "Demo Inventory")
        (extra_vars 
          (foo "bar")))
      (register "result"))
    (task "Launch job template with inventory and credential for prompt on launch"
      (job_launch 
        (job_template (jinja "{{ jt_name2 }}"))
        (organization "Default"))
      (register "result"))
    (task
      (assert 
        (that (list
            "result is changed"))))
    (task "Wait for a job template to complete"
      (job_wait 
        (job_id (jinja "{{ result.id }}"))
        (interval "10")
        (timeout "120"))
      (register "result"))
    (task
      (assert 
        (that (list
            "result is not changed"
            "result.status == 'successful'"))))
    (task "Get the job"
      (job_list 
        (query 
          (id (jinja "{{result.id}}"))))
      (register "result"))
    (task
      (assert 
        (that (list
            "{\"foo\": \"bar\"} | to_json in result.results[0].extra_vars"))))
    (task "Delete the first jt"
      (job_template 
        (name (jinja "{{ jt_name1 }}"))
        (project "Demo Project")
        (playbook "hello_world.yml")
        (state "absent"))
      (register "result"))
    (task
      (assert 
        (that (list
            "result is changed"))))
    (task "Delete the second jt"
      (job_template 
        (name (jinja "{{ jt_name2 }}"))
        (project (jinja "{{ proj_name }}"))
        (playbook "debug.yml")
        (state "absent"))
      (register "result"))
    (task
      (assert 
        (that (list
            "result is changed"))))
    (task "Delete the extra_vars project"
      (project 
        (name (jinja "{{ proj_name }}"))
        (organization "Default")
        (state "absent"))
      (register "result"))
    (task
      (assert 
        (that (list
            "result is changed"))))))
