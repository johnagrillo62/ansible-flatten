(playbook "awx_collection/tests/integration/targets/bulk_job_launch/tasks/main.yml"
  (tasks
    (task "Generate a random string for test"
      (set_fact 
        (test_id (jinja "{{ lookup('password', '/dev/null chars=ascii_letters length=16') }}")))
      (when "test_id is not defined"))
    (task "Generate a unique name"
      (set_fact 
        (bulk_job_name "AWX-Collection-tests-bulk_job_launch-" (jinja "{{ test_id }}"))))
    (task "Get our collection package"
      (controller_meta null)
      (register "controller_meta"))
    (task "Generate the name of our plugin"
      (set_fact 
        (plugin_name (jinja "{{ controller_meta.prefix }}") ".controller_api")))
    (task "Get Inventory"
      (set_fact 
        (inventory_id (jinja "{{ lookup(plugin_name, 'inventories', query_params={'name': 'Demo Inventory'}, return_ids=True ) }}"))))
    (task "Create a Job Template"
      (job_template 
        (name (jinja "{{ bulk_job_name }}"))
        (copy_from "Demo Job Template")
        (ask_variables_on_launch "true")
        (ask_inventory_on_launch "true")
        (ask_skip_tags_on_launch "true")
        (allow_simultaneous "true")
        (state "present"))
      (register "jt_result"))
    (task "Create Bulk Job"
      (bulk_job_launch 
        (name (jinja "{{ bulk_job_name }}"))
        (jobs (list
            
            (unified_job_template (jinja "{{ jt_result.id }}"))
            (inventory (jinja "{{ inventory_id }}"))
            (skip_tags "skipfoo,skipbar")
            (extra_data 
              (animal "fish")
              (color "orange"))
            
            (unified_job_template (jinja "{{ jt_result.id }}"))))
        (extra_vars 
          (animal "bear")
          (food "carrot"))
        (skip_tags "skipbaz")
        (job_tags "Hello World")
        (limit "localhost")
        (wait "True")
        (inventory "Demo Inventory")
        (organization "Default"))
      (register "result"))
    (task
      (assert 
        (that (list
            "result is not failed"
            "'id' in result"
            "result['job_info']['skip_tags'] == \"skipbaz\""
            "result['job_info']['limit'] == \"localhost\""
            "result['job_info']['job_tags'] == \"Hello World\""
            "result['job_info']['inventory'] == inventory_id | int"
            "result['job_info']['extra_vars'] == '{\"animal\": \"bear\", \"food\": \"carrot\"}'"))))
    (task "Delete Job Template"
      (job_template 
        (name (jinja "{{ bulk_job_name }}"))
        (state "absent"))
      (register "del_res")
      (until "del_res is succeeded")
      (retries "5")
      (delay "3"))))
