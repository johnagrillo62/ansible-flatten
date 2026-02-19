(playbook "debops/docs/ansible/roles/rabbitmq_server/examples/example-config-sections.yml"
  (rabbitmq_server__config (list
      
      (name "rabbit")
      (weight "1")
      
      (name "rabbitmq_management")
      (comment "RabbitMQ Management Plugin

See https://www.rabbitmq.com/management.html for details
")
      (options (list))
      (weight "2")
      
      (name "rabbitmq_management_agent")
      (weight "3"))))
