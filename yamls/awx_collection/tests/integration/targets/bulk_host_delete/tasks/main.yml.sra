(playbook "awx_collection/tests/integration/targets/bulk_host_delete/tasks/main.yml"
  (tasks
    (task "Generate a random string for test"
      (set_fact 
        (test_id (jinja "{{ lookup('password', '/dev/null chars=ascii_letters length=16') }}")))
      (when "test_id is not defined"))
    (task "Generate a unique name"
      (set_fact 
        (bulk_inv_name "AWX-Collection-tests-bulk_host_create-" (jinja "{{ test_id }}"))))
    (task "Get our collection package"
      (controller_meta null)
      (register "controller_meta"))
    (task "Generate the name of our plugin"
      (set_fact 
        (plugin_name (jinja "{{ controller_meta.prefix }}") ".controller_api")))
    (task "Create an inventory"
      (inventory 
        (name (jinja "{{ bulk_inv_name }}"))
        (organization "Default")
        (state "present"))
      (register "inventory_result"))
    (task "Bulk Host Create"
      (bulk_host_create 
        (hosts (list
            
            (name "123.456.789.123")
            (description "myhost1")
            (variables 
              (food "carrot")
              (color "orange"))
            
            (name "example.dns.gg")
            (description "myhost2")
            (enabled "false")))
        (inventory (jinja "{{ bulk_inv_name }}")))
      (register "result"))
    (task
      (assert 
        (that (list
            "result is not failed"))))
    (task "Get our collection package"
      (controller_meta null)
      (register "controller_meta"))
    (task "Generate the name of our plugin"
      (set_fact 
        (plugin_name (jinja "{{ controller_meta.prefix }}") ".controller_api")))
    (task "Setting the inventory hosts endpoint"
      (set_fact 
        (endpoint "inventories/" (jinja "{{ inventory_result.id }}") "/hosts/")))
    (task "Get hosts information from inventory"
      (set_fact 
        (hosts_created (jinja "{{ query(plugin_name, endpoint, return_objects=True) }}"))
        (host_id_list (list))))
    (task "Extract host IDs from hosts information"
      (set_fact 
        (host_id_list (jinja "{{ host_id_list + [item.id] }}")))
      (loop (jinja "{{ hosts_created }}")))
    (task "Bulk Host Delete"
      (bulk_host_delete 
        (hosts (jinja "{{ host_id_list }}")))
      (register "result"))
    (task
      (assert 
        (that (list
            "result is not failed"))))
    (task "Delete inventory"
      (inventory 
        (name (jinja "{{ bulk_inv_name }}"))
        (organization "Default")
        (state "absent")))))
