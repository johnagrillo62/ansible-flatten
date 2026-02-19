(playbook "awx_collection/tests/integration/targets/export/tasks/main.yml"
  (tasks
    (task "Generate a random string for test"
      (set_fact 
        (test_id (jinja "{{ lookup('password', '/dev/null chars=ascii_letters length=16') }}")))
      (when "test_id is not defined"))
    (task "Generate names"
      (set_fact 
        (org_name1 "AWX-Collection-tests-export-organization-" (jinja "{{ test_id }}"))
        (org_name2 "AWX-Collection-tests-export-organization2-" (jinja "{{ test_id }}"))
        (inventory_name1 "AWX-Collection-tests-export-inv1-" (jinja "{{ test_id }}"))))
    (task
      (block (list
          
          (name "Create some organizations")
          (organization 
            (name (jinja "{{ item }}")))
          (loop (list
              (jinja "{{ org_name1 }}")
              (jinja "{{ org_name2 }}")))
          
          (name "Create an inventory")
          (inventory 
            (name (jinja "{{ inventory_name1 }}"))
            (organization (jinja "{{ org_name1 }}")))
          
          (name "Export all assets")
          (export 
            (all "true"))
          (register "all_assets")
          
          (assert 
            (that (list
                "all_assets is not changed"
                "all_assets is successful"
                "all_assets['assets']['organizations'] | length() >= 2")))
          
          (name "Export all inventories")
          (export 
            (inventory "all"))
          (register "inventory_export")
          
          (assert 
            (that (list
                "inventory_export is successful"
                "inventory_export is not changed"
                "inventory_export['assets']['inventory'] | length() >= 1"
                "'organizations' not in inventory_export['assets']")))
          
          (name "Export an all and a specific")
          (export 
            (inventory "all")
            (organizations (jinja "{{ org_name1 }}")))
          (register "mixed_export")
          
          (assert 
            (that (list
                "mixed_export is successful"
                "mixed_export is not changed"
                "mixed_export['assets']['inventory'] | length() >= 1"
                "mixed_export['assets']['organizations'] | length() == 1"
                "'workflow_job_templates' not in mixed_export['assets']")))
          
          (name "Export list of organizations")
          (export 
            (organizations (jinja "{{[org_name1, org_name2]}}")))
          (register "list_asserts")
          
          (assert 
            (that (list
                "list_asserts is not changed"
                "list_asserts is successful"
                "list_asserts['assets']['organizations'] | length() >= 2")))
          
          (name "Export list with one organization")
          (export 
            (organizations (jinja "{{[org_name1]}}")))
          (register "list_asserts")
          
          (assert 
            (that (list
                "list_asserts is not changed"
                "list_asserts is successful"
                "list_asserts['assets']['organizations'] | length() >= 1"
                "org_name1 in (list_asserts['assets']['organizations'] | map(attribute='name') )")))
          
          (name "Export one organization as string")
          (export 
            (organizations (jinja "{{org_name2}}")))
          (register "string_asserts")
          
          (assert 
            (that (list
                "string_asserts is not changed"
                "string_asserts is successful"
                "string_asserts['assets']['organizations'] | length() >= 1"
                "org_name2 in (string_asserts['assets']['organizations'] | map(attribute='name') )")))))
      (always (list
          
          (name "Remove our inventory")
          (inventory 
            (name (jinja "{{ inventory_name1 }}"))
            (organization (jinja "{{ org_name1 }}"))
            (state "absent"))
          
          (name "Remove test organizations")
          (organization 
            (name (jinja "{{ item }}"))
            (state "absent"))
          (loop (list
              (jinja "{{ org_name1 }}")
              (jinja "{{ org_name2 }}"))))))))
