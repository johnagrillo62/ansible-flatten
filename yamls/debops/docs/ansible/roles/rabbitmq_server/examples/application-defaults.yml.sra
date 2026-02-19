(playbook "debops/docs/ansible/roles/rabbitmq_server/examples/application-defaults.yml"
  (application__deploy_state "present")
  (application__rabbitmq_server__dependent_config (list
      
      (name "application_name")
      (options (list
          
          (name "config_first_option")
          (value "value1")
          
          (config_second_option "value2"))))))
