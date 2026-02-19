(playbook "sensu-ansible/tasks/dashboard.yml"
  (tasks
    (task "Include ansible_distribution vars"
      (include_tasks (jinja "{{ role_path }}") "/tasks/" (jinja "{{ ansible_distribution }}") "/dashboard.yml")
      (tags "dashboard"))
    (task "Ensure Uchiwa/Sensu Enterprise Dashboard server service is running"
      (service 
        (name (jinja "{{ uchiwa_service_name if not se_enterprise else sensu_enterprise_dashboard_service_name }}"))
        (state "started")
        (enabled "yes"))
      (tags "dashboard"))))
