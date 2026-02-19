(playbook "awx_collection/tests/integration/targets/inventory_source_update/tasks/main.yml"
  (tasks
    (task "Generate a test ID"
      (set_fact 
        (test_id (jinja "{{ lookup('password', '/dev/null chars=ascii_letters length=16') }}")))
      (when "test_id is not defined"))
    (task "Generate names"
      (set_fact 
        (project_name "AWX-Collection-tests-inventory_source_update-project-" (jinja "{{ test_id }}"))
        (inv_name "AWX-Collection-tests-inventory_source_update-inv-" (jinja "{{ test_id }}"))
        (inv_source1 "AWX-Collection-tests-inventory_source_update-source1-" (jinja "{{ test_id }}"))
        (inv_source2 "AWX-Collection-tests-inventory_source_update-source2-" (jinja "{{ test_id }}"))
        (inv_source3 "AWX-Collection-tests-inventory_source_update-source3-" (jinja "{{ test_id }}"))
        (org_name "AWX-Collection-tests-inventory_source_update-org-" (jinja "{{ test_id }}"))))
    (task
      (block (list
          
          (name "Create a new organization")
          (organization 
            (name (jinja "{{ org_name }}")))
          (register "created_org")
          
          (name "Create a git project without credentials")
          (project 
            (name (jinja "{{ project_name }}"))
            (organization (jinja "{{ org_name }}"))
            (scm_type "git")
            (scm_url "https://github.com/ansible/ansible-tower-samples")
            (wait "true"))
          
          (name "Create a git project with same name, different org")
          (project 
            (name (jinja "{{ project_name }}"))
            (organization "Default")
            (scm_type "git")
            (scm_url "https://github.com/ansible/test-playbooks")
            (wait "true"))
          
          (name "Create an Inventory")
          (inventory 
            (name (jinja "{{ inv_name }}"))
            (organization (jinja "{{ org_name }}"))
            (state "present"))
          
          (name "Create another inventory w/ same name, different org")
          (inventory 
            (name (jinja "{{ inv_name }}"))
            (organization "Default")
            (state "present"))
          (register "created_inventory")
          
          (name "Create an Inventory Source (specifically connected to the randomly generated org)")
          (inventory_source 
            (name (jinja "{{ inv_source1 }}"))
            (source "scm")
            (source_project (jinja "{{ project_name }}"))
            (source_path "inventories/inventory.ini")
            (description "Source for Test inventory")
            (organization (jinja "{{ created_org.id }}"))
            (inventory (jinja "{{ inv_name }}")))
          
          (name "Create Another Inventory Source")
          (inventory_source 
            (name (jinja "{{ inv_source2 }}"))
            (source "scm")
            (source_project (jinja "{{ project_name }}"))
            (source_path "inventories/create_10_hosts.ini")
            (description "Source for Test inventory")
            (organization "Default")
            (inventory (jinja "{{ inv_name }}")))
          
          (name "Create Yet Another Inventory Source (to make lookup plugin find multiple inv sources)")
          (inventory_source 
            (name (jinja "{{ inv_source3 }}"))
            (source "scm")
            (source_project (jinja "{{ project_name }}"))
            (source_path "inventories/create_100_hosts.ini")
            (description "Source for Test inventory")
            (organization "Default")
            (inventory (jinja "{{ inv_name }}")))
          
          (name "Test Inventory Source Update")
          (inventory_source_update 
            (name (jinja "{{ inv_source2 }}"))
            (inventory (jinja "{{ inv_name }}"))
            (organization "Default"))
          (register "result")
          
          (assert 
            (that (list
                "result is changed")))
          
          (name "Test Inventory Source Update for All Sources")
          (inventory_source_update 
            (name (jinja "{{ item.name }}"))
            (inventory (jinja "{{ inv_name }}"))
            (organization "Default")
            (wait "true"))
          (loop (jinja "{{ query('awx.awx.controller_api', 'inventory_sources', query_params={ 'inventory': created_inventory.id }, expect_objects=True, return_objects=True) }}"))
          (loop_control 
            (label (jinja "{{ item.name }}")))
          (register "result")
          
          (assert 
            (that (list
                "result is changed")))
          
          (name "Test Inventory Source Update for All Sources (using inventory_source as alias for name)")
          (inventory_source_update 
            (inventory_source (jinja "{{ item.name }}"))
            (inventory (jinja "{{ inv_name }}"))
            (organization "Default")
            (wait "true"))
          (loop (jinja "{{ query('awx.awx.controller_api', 'inventory_sources', query_params={ 'inventory': created_inventory.id }, expect_objects=True, return_objects=True) }}"))
          (loop_control 
            (label (jinja "{{ item.name }}")))
          (register "result")
          
          (assert 
            (that (list
                "result is changed")))
          
          (name "Attempt to delete an inventory source from an inventory that does not exist")
          (inventory_source 
            (name (jinja "{{ inv_source3 }}"))
            (source "scm")
            (state "absent")
            (source_project (jinja "{{ project_name }}"))
            (source_path "inventories/create_100_hosts.ini")
            (description "Source for Test inventory")
            (organization "Default")
            (inventory "Does not exist"))
          (register "result")
          
          (assert 
            (that (list
                "result is not changed")))))
      (always (list
          
          (name "Delete Inventory")
          (inventory 
            (name (jinja "{{ inv_name }}"))
            (organization "Default")
            (state "absent"))
          
          (name "Delete Project")
          (project 
            (name (jinja "{{ project_name }}"))
            (organization "Default")
            (state "absent"))
          
          (name "Remove the organization")
          (organization 
            (name (jinja "{{ org_name }}"))
            (state "absent")))))))
