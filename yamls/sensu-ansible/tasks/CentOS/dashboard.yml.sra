(playbook "sensu-ansible/tasks/CentOS/dashboard.yml"
  (tasks
    (task "Include ansible_distribution vars"
      (include_vars 
        (file (jinja "{{ ansible_distribution }}") ".yml"))
      (tags "dashboard"))
    (task "Ensure Uchiwa is installed"
      (package 
        (name (list
            "chkconfig"
            "uchiwa"))
        (state "present"))
      (tags "dashboard")
      (when "not se_enterprise"))
    (task "Ensure Sensu Enterprise Dashboard is installed"
      (package 
        (name (jinja "{{ sensu_enterprise_dashboard_package }}"))
        (state "present"))
      (tags "dashboard")
      (when "se_enterprise"))
    (task "Deploy Uchiwa config"
      (template 
        (src "uchiwa_config.json.j2")
        (dest (jinja "{{ sensu_config_path }}") "/uchiwa.json"))
      (tags "dashboard")
      (when "not se_enterprise")
      (notify (list
          "restart uchiwa service")))
    (task "Deploy Sensu Enterprise Dashboard"
      (template 
        (src "sensu_enterprise_dashboard_config.json.j2")
        (dest (jinja "{{ sensu_config_path }}") "/dashboard.json"))
      (tags "dashboard")
      (when "se_enterprise")
      (notify (list
          "restart sensu-enterprise-dashboard service")))))
