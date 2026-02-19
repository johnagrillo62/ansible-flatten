(playbook "sensu-ansible/tasks/common.yml"
  (tasks
    (task "Include ansible_distribution vars"
      (include_vars 
        (file (jinja "{{ ansible_distribution }}") ".yml")))
    (task "Ensure the Sensu config directory is present"
      (file 
        (dest (jinja "{{ sensu_config_path }}") "/conf.d")
        (state "directory")
        (owner (jinja "{{ sensu_user_name }}"))
        (group (jinja "{{ sensu_group_name }}"))
        (mode "0555")))
    (task "Deploy Sensu Redis configuration"
      (template 
        (dest (jinja "{{ sensu_config_path }}") "/conf.d/redis.json")
        (owner (jinja "{{ sensu_user_name }}"))
        (group (jinja "{{ sensu_group_name }}"))
        (src (jinja "{{ sensu_redis_config }}"))
        (mode "0640"))
      (when "sensu_deploy_redis_config")
      (notify (list
          "restart sensu-server service"
          "restart sensu-api service"
          "restart sensu-enterprise service"
          "restart sensu-client service")))
    (task "Deploy Sensu RabbitMQ configuration"
      (template 
        (dest (jinja "{{ sensu_config_path }}") "/conf.d/rabbitmq.json")
        (owner (jinja "{{ sensu_user_name }}"))
        (group (jinja "{{ sensu_group_name }}"))
        (src (jinja "{{ sensu_rabbitmq_config }}"))
        (mode "0640"))
      (when "sensu_transport == \"rabbitmq\" and sensu_deploy_rabbitmq_config")
      (notify (list
          "restart sensu-server service"
          "restart sensu-api service"
          "restart sensu-enterprise service"
          "restart sensu-client service")))
    (task "Deploy Sensu transport configuration"
      (template 
        (dest (jinja "{{ sensu_config_path }}") "/conf.d/transport.json")
        (owner (jinja "{{ sensu_user_name }}"))
        (group (jinja "{{ sensu_group_name }}"))
        (src "transport.json.j2")
        (mode "0640"))
      (when "sensu_deploy_transport_config")
      (notify (list
          "restart sensu-server service"
          "restart sensu-api service"
          "restart sensu-enterprise service"
          "restart sensu-client service")))))
