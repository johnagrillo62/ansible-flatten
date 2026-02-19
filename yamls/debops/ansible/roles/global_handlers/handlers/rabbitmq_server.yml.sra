(playbook "debops/ansible/roles/global_handlers/handlers/rabbitmq_server.yml"
  (tasks
    (task "Restart rabbitmq-server"
      (ansible.builtin.service 
        (name "rabbitmq-server")
        (state "restarted")))))
