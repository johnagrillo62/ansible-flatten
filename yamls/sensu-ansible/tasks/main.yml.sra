(playbook "sensu-ansible/tasks/main.yml"
  (tasks
    (task "Include distribution specific variables"
      (include_vars 
        (file (jinja "{{ ansible_distribution }}") ".yml")))
    (task
      (include_tasks (jinja "{{ role_path }}") "/tasks/" (jinja "{{ ansible_distribution }}") "/main.yml")
      (tags "setup")
      (when "sensu_master or sensu_client"))
    (task
      (import_tasks "redis.yml")
      (tags "redis")
      (when "sensu_redis_server and sensu_deploy_redis_server"))
    (task
      (import_tasks "ssl.yml")
      (tags "ssl"))
    (task
      (import_tasks "rabbit.yml")
      (tags "rabbitmq")
      (when "sensu_rabbitmq_server and sensu_deploy_rabbitmq_server"))
    (task
      (import_tasks "common.yml")
      (tags "common")
      (when "sensu_master or sensu_client"))
    (task
      (import_tasks "server.yml")
      (tags "server")
      (when "sensu_master"))
    (task
      (import_tasks "dashboard.yml")
      (tags "dashboard")
      (when "sensu_include_dashboard"))
    (task
      (import_tasks "client.yml")
      (tags "client")
      (when "sensu_client"))
    (task
      (import_tasks "plugins.yml")
      (tags "plugins")
      (when "sensu_include_plugins"))))
