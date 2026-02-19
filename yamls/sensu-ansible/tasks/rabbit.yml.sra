(playbook "sensu-ansible/tasks/rabbit.yml"
  (tasks
    (task "Include ansible_distribution vars"
      (include_vars 
        (file (jinja "{{ ansible_distribution }}") ".yml"))
      (tags "rabbitmq"))
    (task
      (include_tasks (jinja "{{ ansible_distribution }}") "/rabbit.yml")
      (tags "rabbitmq"))
    (task "Ensure RabbitMQ SSL directory exists"
      (file 
        (dest (jinja "{{ sensu_rabbitmq_config_path }}") "/ssl")
        (state "directory"))
      (tags "rabbitmq"))
    (task "Ensure RabbitMQ SSL certs/keys are in place"
      (copy 
        (src (jinja "{{ item.src }}"))
        (dest (jinja "{{ sensu_rabbitmq_config_path }}") "/ssl/" (jinja "{{ item.dest }}"))
        (remote_src (jinja "{{ sensu_ssl_deploy_remote_src }}")))
      (tags "rabbitmq")
      (loop (list
          
          (src (jinja "{{ sensu_ssl_server_cacert }}"))
          (dest "cacert.pem")
          
          (src (jinja "{{ sensu_ssl_server_cert }}"))
          (dest "cert.pem")
          
          (src (jinja "{{ sensu_ssl_server_key }}"))
          (dest "key.pem")))
      (notify (list
          "restart rabbitmq service"
          "restart sensu-api service"
          "restart sensu-server service"
          "restart sensu-enterprise service"))
      (when "sensu_ssl_manage_certs"))
    (task "Deploy RabbitMQ config"
      (template 
        (dest (jinja "{{ sensu_rabbitmq_config_path }}") "/rabbitmq.config")
        (src (jinja "{{ sensu_rabbitmq_config_template }}"))
        (owner "root")
        (group (jinja "{{ __root_group }}"))
        (mode "0644"))
      (tags "rabbitmq")
      (notify "restart rabbitmq service"))
    (task "Ensure RabbitMQ is running"
      (service 
        (name (jinja "{{ sensu_rabbitmq_service_name }}"))
        (state "started")
        (enabled "true"))
      (tags "rabbitmq")
      (register "sensu_rabbitmq_state"))
    (task "Wait for RabbitMQ to be up and running before asking to create a vhost"
      (pause 
        (seconds "3"))
      (tags "rabbitmq")
      (when "sensu_rabbitmq_state is changed"))
    (task
      (block (list
          
          (name "Ensure Sensu RabbitMQ vhost exists")
          (rabbitmq_vhost 
            (name (jinja "{{ sensu_rabbitmq_vhost }}"))
            (state "present"))
          
          (name "Ensure Sensu RabbitMQ user has access to the Sensu vhost")
          (rabbitmq_user 
            (user (jinja "{{ sensu_rabbitmq_user_name }}"))
            (password (jinja "{{ sensu_rabbitmq_password }}"))
            (vhost (jinja "{{ sensu_rabbitmq_vhost }}"))
            (configure_priv ".*")
            (read_priv ".*")
            (write_priv ".*")
            (state "present"))))
      (become "true")
      (become_user "rabbitmq")
      (tags "rabbitmq"))))
