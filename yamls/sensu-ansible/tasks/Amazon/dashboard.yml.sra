(playbook "sensu-ansible/tasks/Amazon/dashboard.yml"
  (tasks
    (task "Include ansible_distribution vars"
      (include_vars 
        (file (jinja "{{ ansible_distribution }}") ".yml"))
      (tags "dashboard"))
    (task "Ensure Uchiwa is installed"
      (yum 
        (name "uchiwa")
        (state "present"))
      (tags "dashboard"))
    (task "Deploy Uchiwa config"
      (template 
        (src "uchiwa_config.json.j2")
        (dest (jinja "{{ sensu_config_path }}") "/uchiwa.json"))
      (tags "dashboard")
      (notify "restart uchiwa service"))))
