(playbook "awx_collection/tests/integration/targets/instance/tasks/main.yml"
  (tasks
    (task "Generate a test ID"
      (ansible.builtin.set_fact 
        (test_id (jinja "{{ lookup('password', '/dev/null chars=ascii_letters length=16') }}")))
      (when "test_id is not defined"))
    (task "Generate hostnames"
      (ansible.builtin.set_fact 
        (hostname1 "AWX-Collection-tests-instance1." (jinja "{{ test_id }}") ".example.com")
        (hostname2 "AWX-Collection-tests-instance2." (jinja "{{ test_id }}") ".example.com")
        (hostname3 "AWX-Collection-tests-instance3." (jinja "{{ test_id }}") ".example.com"))
      (register "facts"))
    (task "Get the k8s setting"
      (ansible.builtin.set_fact 
        (IS_K8S (jinja "{{ controller_settings['IS_K8S'] | default(False) }}")))
      (vars 
        (controller_settings (jinja "{{ lookup('awx.awx.controller_api', 'settings/all') }}"))))
    (task
      (ansible.builtin.debug 
        (msg "Skipping instance test since this is instance is not running on a K8s platform"))
      (when "not IS_K8S"))
    (task
      (block (list
          
          (name "Create an instance")
          (awx.awx.instance 
            (hostname (jinja "{{ item }}"))
            (node_type "execution")
            (node_state "installed"))
          (with_items (list
              (jinja "{{ hostname1 }}")
              (jinja "{{ hostname2 }}")))
          (register "result")
          
          (ansible.builtin.assert 
            (that (list
                "result is changed")))
          
          (name "Create an instance with non-default config")
          (awx.awx.instance 
            (hostname (jinja "{{ hostname3 }}"))
            (node_type "execution")
            (node_state "installed")
            (capacity_adjustment "0.4"))
          (register "result")
          
          (ansible.builtin.assert 
            (that (list
                "result is changed")))
          
          (name "Update an instance")
          (awx.awx.instance 
            (hostname (jinja "{{ hostname1 }}"))
            (capacity_adjustment "0.7"))
          (register "result")
          
          (ansible.builtin.assert 
            (that (list
                "result is changed")))))
      (always (list
          
          (name "Deprovision the instances")
          (awx.awx.instance 
            (hostname (jinja "{{ item }}"))
            (node_state "deprovisioning"))
          (with_items (list
              (jinja "{{ hostname1 }}")
              (jinja "{{ hostname2 }}")
              (jinja "{{ hostname3 }}")))))
      (when "IS_K8S"))
    (task
      (block (list
          
          (name "Create hop node 1")
          (awx.awx.instance 
            (hostname (jinja "{{ hostname1 }}"))
            (node_type "hop")
            (node_state "installed"))
          (register "result")
          
          (ansible.builtin.assert 
            (that (list
                "result is changed")))
          
          (name "Create hop node 2")
          (awx.awx.instance 
            (hostname (jinja "{{ hostname2 }}"))
            (node_type "hop")
            (node_state "installed"))
          (register "result")
          
          (ansible.builtin.assert 
            (that (list
                "result is changed")))
          
          (name "Create execution node")
          (awx.awx.instance 
            (hostname (jinja "{{ hostname3 }}"))
            (node_type "execution")
            (node_state "installed")
            (peers (list
                (jinja "{{ hostname1 }}")
                (jinja "{{ hostname2 }}"))))
          (register "result")
          
          (ansible.builtin.assert 
            (that (list
                "result is changed")))
          
          (name "Remove execution node peers")
          (awx.awx.instance 
            (hostname (jinja "{{ hostname3 }}"))
            (node_type "execution")
            (node_state "installed")
            (peers (list)))
          (register "result")
          
          (ansible.builtin.assert 
            (that (list
                "result is changed")))))
      (always (list
          
          (name "Deprovision the instances")
          (awx.awx.instance 
            (hostname (jinja "{{ item }}"))
            (node_state "deprovisioning"))
          (with_items (list
              (jinja "{{ hostname1 }}")
              (jinja "{{ hostname2 }}")
              (jinja "{{ hostname3 }}")))))
      (when "IS_K8S"))))
