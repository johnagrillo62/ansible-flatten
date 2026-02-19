(playbook "awx_collection/tests/integration/targets/import/tasks/main.yml"
  (tasks
    (task "Generate a random string for test"
      (set_fact 
        (test_id (jinja "{{ lookup('password', '/dev/null chars=ascii_letters length=16') }}")))
      (when "test_id is not defined"))
    (task "Generate names"
      (set_fact 
        (org_name1 "AWX-Collection-tests-import-organization-" (jinja "{{ test_id }}"))
        (org_name2 "AWX-Collection-tests-import-organization2-" (jinja "{{ test_id }}"))))
    (task
      (block (list
          
          (name "Import something")
          (import 
            (assets 
              (organizations (list
                  
                  (name (jinja "{{ org_name1 }}"))
                  (description "")
                  (max_hosts "0")
                  (related 
                    (notification_templates (list))
                    (notification_templates_started (list))
                    (notification_templates_success (list))
                    (notification_templates_error (list))
                    (notification_templates_approvals (list)))
                  (natural_key 
                    (name (jinja "{{ org_name1 }}"))
                    (type "organization"))))))
          (register "import_output")
          
          (assert 
            (that (list
                "import_output is changed")))
          
          (name "Import the same thing again")
          (import 
            (assets 
              (organizations (list
                  
                  (name (jinja "{{ org_name1 }}"))
                  (description "")
                  (max_hosts "0")
                  (related 
                    (notification_templates (list))
                    (notification_templates_started (list))
                    (notification_templates_success (list))
                    (notification_templates_error (list))
                    (notification_templates_approvals (list)))
                  (natural_key 
                    (name (jinja "{{ org_name1 }}"))
                    (type "organization"))))))
          (register "import_output")
          (ignore_errors "yes")
          
          (assert 
            (that (list
                "import_output is not failed")))
          
          (name "Write out a json file")
          (copy 
            (content "{
     \"organizations\": [
          {
               \"name\": \"" (jinja "{{ org_name2 }}") "\",
               \"description\": \"\",
               \"max_hosts\": 0,
               \"related\": {
                    \"notification_templates\": [],
                    \"notification_templates_started\": [],
                    \"notification_templates_success\": [],
                    \"notification_templates_error\": [],
                    \"notification_templates_approvals\": []
               },
               \"natural_key\": {
                    \"name\": \"" (jinja "{{ org_name2 }}") "\",
                    \"type\": \"organization\"
               }
          }
     ]
}
")
            (dest "./org.json"))
          
          (name "Load assets from a file")
          (import 
            (assets (jinja "{{ lookup('file', 'org.json') | from_json() }}")))
          (register "import_output")
          
          (assert 
            (that (list
                "import_output is changed")))))
      (always (list
          
          (name "Remove organizations")
          (organization 
            (name (jinja "{{ item }}"))
            (state "absent"))
          (loop (list
              (jinja "{{ org_name1 }}")
              (jinja "{{ org_name2 }}")))
          
          (name "Delete org.json")
          (file 
            (path "./org.json")
            (state "absent")))))))
