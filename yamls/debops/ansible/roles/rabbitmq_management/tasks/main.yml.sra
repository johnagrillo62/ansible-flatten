(playbook "debops/ansible/roles/rabbitmq_management/tasks/main.yml"
  (tasks
    (task "Manage RabbitMQ plugins"
      (community.rabbitmq.rabbitmq_plugin 
        (names (jinja "{{ (rabbitmq_management__default_plugins
                + rabbitmq_management__plugins) | join(\",\") }}"))
        (state (jinja "{{ \"enabled\" if rabbitmq_management__deploy_state != \"absent\" else \"disabled\" }}"))
        (new_only "True"))
      (when "rabbitmq_management__local | bool"))))
