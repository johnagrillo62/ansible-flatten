(playbook "debops/ansible/roles/rabbitmq_management/defaults/main.yml"
  (rabbitmq_management__local "True")
  (rabbitmq_management__deploy_state "present")
  (rabbitmq_management__fqdn "rabbitmq." (jinja "{{ rabbitmq_management__domain }}"))
  (rabbitmq_management__domain (jinja "{{ ansible_domain }}"))
  (rabbitmq_management__webserver_allow (list))
  (rabbitmq_management__default_plugins (list
      "rabbitmq_management"))
  (rabbitmq_management__plugins (list))
  (rabbitmq_management__app_port "15672")
  (rabbitmq_management__app_bind "::")
  (rabbitmq_management__app_host (jinja "{{ ansible_fqdn }}"))
  (rabbitmq_management__app_protocol (jinja "{{ \"http\"
                                       if rabbitmq_management__local | bool
                                       else \"https\" }}"))
  (rabbitmq_management__default_config (list
      
      (name "rabbitmq_management")
      (state (jinja "{{ rabbitmq_management__deploy_state }}"))
      (options (list
          
          (name "listener")
          (value "[{port, " (jinja "{{ rabbitmq_management__app_port + '}' }}") ",
 {ip, \"" (jinja "{{ rabbitmq_management__app_bind }}") "\"}]
")
          (comment "Communication with the Management Console is done using
a reverse proxy at 'https://" (jinja "{{ rabbitmq_management__fqdn }}") "/'
")
          (type "raw")))))
  (rabbitmq_management__config (list))
  (rabbitmq_management__etc_services__dependent_list (list
      
      (name "rabbitmq-mgmt")
      (port (jinja "{{ rabbitmq_management__app_port }}"))
      (comment "RabbitMQ Management Console")
      (state (jinja "{{ rabbitmq_management__deploy_state }}"))))
  (rabbitmq_management__rabbitmq_server__dependent_config (list
      (jinja "{{ rabbitmq_management__default_config }}")
      (jinja "{{ rabbitmq_management__config }}")))
  (rabbitmq_management__nginx__dependent_servers (list
      
      (name (jinja "{{ rabbitmq_management__fqdn }}"))
      (by_role "debops.rabbitmq_management")
      (filename "debops.rabbitmq_management")
      (state (jinja "{{ rabbitmq_management__deploy_state }}"))
      (type "proxy")
      (proxy_pass (jinja "{{ rabbitmq_management__app_protocol }}") "://rabbitmq_management")
      (proxy_redirect "default")
      (allow (jinja "{{ rabbitmq_management__webserver_allow }}"))))
  (rabbitmq_management__nginx__dependent_upstreams (list
      
      (name "rabbitmq_management")
      (server (jinja "{{ rabbitmq_management__app_host + \":\" + rabbitmq_management__app_port }}"))
      (state (jinja "{{ rabbitmq_management__deploy_state }}")))))
