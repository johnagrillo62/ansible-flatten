(playbook "tools/docker-compose/ansible/plumb_splunk.yml"
    (play
    (name "Plumb a splunk instance")
    (hosts "localhost")
    (connection "local")
    (gather_facts "False")
    (vars
      (awx_host "https://localhost:8043"))
    (collections (list
        "splunk.es"))
    (tasks
      (task "create splunk_data_input_network"
        (splunk.es.data_input_network 
          (name "9199")
          (protocol "tcp")
          (source "http:tower_logging_collections")
          (sourcetype "httpevent")
          (state "present"))
        (vars 
          (ansible_network_os "splunk.es.splunk")
          (ansible_user "admin")
          (ansible_httpapi_pass "splunk_admin")
          (ansible_httpapi_port "8089")
          (ansible_httpapi_use_ssl "yes")
          (ansible_httpapi_validate_certs "False")
          (ansible_connection "httpapi")))
      (task "Load existing and new Logging settings"
        (ansible.builtin.set_fact 
          (existing_logging (jinja "{{ lookup('awx.awx.controller_api', 'settings/logging', host=awx_host, verify_ssl=false) }}"))
          (new_logging (jinja "{{ lookup('template', 'logging.json.j2') }}"))))
      
      (pause 
        (ansible.builtin.prompt "Continuing to run this will replace your existing logging settings (displayed above). They will all be captured except for your connection password. Be sure that is backed up before continuing"))
      (task "Write out the existing content"
        (ansible.builtin.copy 
          (dest "../_sources/existing_logging.json")
          (content (jinja "{{ existing_logging }}"))))
      (task "Configure AWX logging adapter"
        (awx.awx.settings 
          (settings (jinja "{{ new_logging }}"))
          (controller_host (jinja "{{ awx_host }}"))
          (validate_certs "False"))))))
