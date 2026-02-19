(playbook "sensu-ansible/tasks/client.yml"
  (tasks
    (task "Include ansible_distribution vars"
      (include_vars 
        (file (jinja "{{ ansible_distribution }}") ".yml"))
      (tags "client"))
    (task "Deploy Sensu client service configuration"
      (template 
        (dest (jinja "{{ sensu_config_path }}") "/conf.d/client.json")
        (owner (jinja "{{ sensu_user_name }}"))
        (group (jinja "{{ sensu_group_name }}"))
        (src (jinja "{{ sensu_client_config  }}"))
        (mode "0640"))
      (tags "client")
      (notify "restart sensu-client service"))
    (task
      (include_tasks (jinja "{{ role_path }}") "/tasks/SmartOS/client.yml")
      (tags "client")
      (when "ansible_distribution == \"SmartOS\""))
    (task "Ensure Sensu client service is running"
      (service 
        (name (jinja "{{ sensu_client_service_name }}"))
        (state "started")
        (enabled "yes"))
      (tags "client"))))
