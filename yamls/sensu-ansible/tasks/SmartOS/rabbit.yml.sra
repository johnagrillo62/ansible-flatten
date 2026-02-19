(playbook "sensu-ansible/tasks/SmartOS/rabbit.yml"
  (tasks
    (task "Ensure RabbitMQ is installed"
      (pkgin "name=rabbitmq state=present")
      (tags "rabbitmq"))
    (task "Ensure EPMD is running"
      (service 
        (name "epmd")
        (state "started")
        (enabled "true"))
      (tags "rabbitmq"))))
