(playbook "awx_collection/tests/integration/targets/lookup_api_plugin/tasks/main.yml"
  (tasks
    (task "Generate a random string for test"
      (ansible.builtin.set_fact 
        (test_id (jinja "{{ lookup('password', '/dev/null chars=ascii_letters length=16') }}")))
      (when "test_id is not defined"))
    (task "Generate usernames"
      (ansible.builtin.set_fact 
        (usernames (list
            "AWX-Collection-tests-api_lookup-user1-" (jinja "{{ test_id }}")
            "AWX-Collection-tests-api_lookup-user2-" (jinja "{{ test_id }}")
            "AWX-Collection-tests-api_lookup-user3-" (jinja "{{ test_id }}")))
        (hosts (list
            "AWX-Collection-tests-api_lookup-host1-" (jinja "{{ test_id }}")
            "AWX-Collection-tests-api_lookup-host2-" (jinja "{{ test_id }}")))
        (group_name "AWX-Collection-tests-api_lookup-group1-" (jinja "{{ test_id }}"))))
    (task "Get our collection package"
      (controller_meta null)
      (register "controller_meta"))
    (task "Generate the name of our plugin"
      (ansible.builtin.set_fact 
        (plugin_name (jinja "{{ controller_meta.prefix }}") ".controller_api")))
    (task "Create all of our users"
      (user 
        (username (jinja "{{ item }}"))
        (is_superuser "true")
        (password (jinja "{{ test_id }}")))
      (loop (jinja "{{ usernames }}"))
      (register "user_creation_results"))
    (task
      (block (list
          
          (name "Specify the connection params")
          (debug 
            (msg (jinja "{{ query(plugin_name, 'ping', host='DNE://junk.com', username='john', password='not_legit', verify_ssl=True) }}")))
          (register "results")
          (ignore_errors "yes")
          
          (ansible.builtin.assert 
            (that (list
                "'dne' in (results.msg | lower)")))
          
          (name "Create our hosts")
          (host 
            (name (jinja "{{ item }}"))
            (inventory "Demo Inventory"))
          (loop (jinja "{{ hosts }}"))
          
          (name "Test too many params (failure from validation of terms)")
          (ansible.builtin.set_fact 
            (junk (jinja "{{ query(plugin_name, 'users', 'teams', query_params={}, ) }}")))
          (ignore_errors "yes")
          (register "result")
          
          (ansible.builtin.assert 
            (that (list
                "result is failed"
                "'You must pass exactly one endpoint to query' in result.msg")))
          
          (name "Try to load invalid endpoint")
          (ansible.builtin.set_fact 
            (junk (jinja "{{ query(plugin_name, 'john', query_params={}, ) }}")))
          (ignore_errors "yes")
          (register "result")
          
          (ansible.builtin.assert 
            (that (list
                "result is failed"
                "'The requested object could not be found at' in result.msg")))
          
          (name "Load user of a specific name without promoting objects")
          (ansible.builtin.set_fact 
            (users_list (jinja "{{ lookup(plugin_name, 'users', query_params={ 'username' : user_creation_results['results'][0]['item'] }, return_objects=False) }}")))
          
          (ansible.builtin.assert 
            (that (list
                "users_list['results'] | length() == 1"
                "users_list['count'] == 1"
                "users_list['results'][0]['id'] == user_creation_results['results'][0]['id']")))
          
          (name "Load user of a specific name with promoting objects")
          (ansible.builtin.set_fact 
            (user_objects (jinja "{{ query(plugin_name, 'users', query_params={ 'username' : user_creation_results['results'][0]['item'] }, return_objects=True ) }}")))
          
          (ansible.builtin.assert 
            (that (list
                "user_objects | length() == 1"
                "users_list['results'][0]['id'] == user_objects[0]['id']")))
          
          (name "Loop over one user with the loop syntax")
          (ansible.builtin.assert 
            (that (list
                "item['id'] == user_creation_results['results'][0]['id']")))
          (loop (jinja "{{ query(plugin_name, 'users', query_params={ 'username' : user_creation_results['results'][0]['item'] } ) }}"))
          (loop_control 
            (label (jinja "{{ item.id }}")))
          
          (name "Get a page of users as just ids")
          (ansible.builtin.set_fact 
            (users (jinja "{{ query(plugin_name, 'users', query_params={ 'username__endswith': test_id, 'page_size': 2 }, return_ids=True ) }}")))
          
          (debug 
            (msg (jinja "{{ users }}")))
          
          (name "assert that user list has 2 ids only and that they are strings, not ints")
          (ansible.builtin.assert 
            (that (list
                "users | length() == 2"
                "user_creation_results['results'][0]['id'] not in users"
                "user_creation_results['results'][0]['id'] | string in users")))
          
          (name "Get all users of a system through next attribute")
          (ansible.builtin.set_fact 
            (users (jinja "{{ query(plugin_name, 'users', query_params={ 'username__endswith': test_id, 'page_size': 1 }, return_all=true ) }}")))
          
          (ansible.builtin.assert 
            (that (list
                "users | length() >= 3")))
          
          (name "Get all of the users created with a max_objects of 1")
          (ansible.builtin.set_fact 
            (users (jinja "{{ lookup(plugin_name, 'users', query_params={ 'username__endswith': test_id, 'page_size': 1 }, return_all=true, max_objects=1 ) }}")))
          (ignore_errors "yes")
          (register "max_user_errors")
          
          (ansible.builtin.assert 
            (that (list
                "max_user_errors is failed"
                "'List view at users returned 3 objects, which is more than the maximum allowed by max_objects' in max_user_errors.msg")))
          
          (name "Get the ID of the first user created and verify that it is correct")
          (ansible.builtin.assert 
            (that "query(plugin_name, 'users', query_params={ 'username' : user_creation_results['results'][0]['item'] }, return_ids=True)[0] ==  user_creation_results['results'][0]['id'] | string"))
          
          (name "Try to get an ID of someone who does not exist")
          (ansible.builtin.set_fact 
            (failed_user_id (jinja "{{ query(plugin_name, 'users', query_params={ 'username': 'john jacob jingleheimer schmidt' }, expect_one=True) }}")))
          (register "result")
          (ignore_errors "yes")
          
          (ansible.builtin.assert 
            (that (list
                "result is failed"
                "'Expected one object from endpoint users' in result['msg']")))
          
          (name "Lookup too many users")
          (ansible.builtin.set_fact 
            (too_many_user_ids " " (jinja "{{ query(plugin_name, 'users', query_params={ 'username__endswith': test_id }, expect_one=True) }}")))
          (register "results")
          (ignore_errors "yes")
          
          (ansible.builtin.assert 
            (that (list
                "results is failed"
                "'Expected one object from endpoint users, but obtained 3' in results['msg']")))
          
          (name "Get the ping page")
          (ansible.builtin.set_fact 
            (ping_data (jinja "{{ lookup(plugin_name, 'ping' ) }}")))
          (register "results")
          
          (ansible.builtin.assert 
            (that (list
                "results is succeeded"
                "'active_node' in ping_data")))
          
          (name "Make sure that expect_objects fails on an API page")
          (ansible.builtin.set_fact 
            (my_var (jinja "{{ lookup(plugin_name, 'settings/ui', expect_objects=True) }}")))
          (ignore_errors "yes")
          (register "results")
          
          (ansible.builtin.assert 
            (that (list
                "results is failed"
                "'Did not obtain a list or detail view at settings/ui, and expect_objects or expect_one is set to True' in results.msg")))
          
          (name "Load the UI settings")
          (ansible.builtin.set_fact 
            (controller_settings (jinja "{{ lookup('awx.awx.controller_api', 'settings/ui') }}")))
          
          (ansible.builtin.assert 
            (that (list
                "'CUSTOM_LOGO' in controller_settings")))
          
          (name "Display the usernames of all admin users")
          (debug 
            (msg "Admin users: " (jinja "{{ query('awx.awx.controller_api', 'users', query_params={ 'is_superuser': true }) | map(attribute='username') | join(', ') }}")))
          (register "results")
          
          (ansible.builtin.assert 
            (that (list
                "'admin' in results.msg")))
          
          (name "debug all organizations in a loop")
          (debug 
            (msg "Organization description=" (jinja "{{ item['description'] }}") " id=" (jinja "{{ item['id'] }}")))
          (loop (jinja "{{ query('awx.awx.controller_api', 'organizations') }}"))
          (loop_control 
            (label (jinja "{{ item['name'] }}")))
          
          (name "Make sure user 'john' is an org admin of the default org if the user exists")
          (role 
            (organization "Default")
            (role "admin")
            (user (jinja "{{ usernames[0] }}"))
            (state "absent"))
          (register "role_revoke")
          (when "query('awx.awx.controller_api', 'users', query_params={ 'username': 'DNE_TESTING' }) | length  == 1")
          
          (ansible.builtin.assert 
            (that (list
                "role_revoke is skipped")))
          
          (name "Create an inventory group with all 'foo' hosts")
          (group 
            (name (jinja "{{ group_name }}"))
            (inventory "Demo Inventory")
            (hosts (jinja "{{ query(
     'awx.awx.controller_api',
      'hosts',
      query_params={ 'name__endswith' : test_id, },
  ) | map(attribute='name') | list }}")))
          (register "group_creation")
          
          (ansible.builtin.assert 
            (that "group_creation is changed"))))
      (always (list
          
          (name "Cleanup group")
          (group 
            (name (jinja "{{ group_name }}"))
            (inventory "Demo Inventory")
            (state "absent"))
          
          (name "Cleanup hosts")
          (host 
            (name (jinja "{{ item }}"))
            (inventory "Demo Inventory")
            (state "absent"))
          (loop (jinja "{{ hosts }}"))
          
          (name "Cleanup users")
          (user 
            (username (jinja "{{ item }}"))
            (state "absent"))
          (loop (jinja "{{ usernames }}")))))))
