(playbook "sensu-ansible/tasks/server.yml"
  (tasks
    (task "Include ansible_distribution vars"
      (include_vars 
        (file (jinja "{{ ansible_distribution }}") ".yml"))
      (tags "server"))
    (task "Deploy Sensu server API configuration"
      (template 
        (dest (jinja "{{ sensu_config_path }}") "/conf.d/api.json")
        (owner (jinja "{{ sensu_user_name }}"))
        (group (jinja "{{ sensu_group_name }}"))
        (src "sensu-api.json.j2"))
      (tags "server")
      (notify "restart sensu-api service"))
    (task "Deploy Tessen server configuratiuon"
      (template 
        (dest (jinja "{{ sensu_config_path }}") "/conf.d/tessen.json")
        (owner (jinja "{{ sensu_user_name }}"))
        (group (jinja "{{ sensu_group_name }}"))
        (src "sensu-tessen.json.j2"))
      (tags "server")
      (notify "restart sensu-server service"))
    (task
      (include_tasks (jinja "{{ role_path }}") "/tasks/SmartOS/server.yml")
      (tags "server")
      (when "ansible_distribution == \"SmartOS\""))
    (task "Ensure Sensu server service is running"
      (service 
        (name (jinja "{{ sensu_server_service_name if not se_enterprise else sensu_enterprise_service_name }}"))
        (state "started")
        (enabled "yes"))
      (tags "server"))
    (task "Ensure Sensu API service is running"
      (service 
        (name "sensu-api")
        (state "started")
        (enabled "yes"))
      (tags "server")
      (when "not se_enterprise"))))
