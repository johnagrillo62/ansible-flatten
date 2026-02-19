(playbook "sensu-ansible/tasks/FreeBSD/rabbit.yml"
  (tasks
    (task "Include ansible_distribution vars"
      (include_vars 
        (file (jinja "{{ ansible_distribution }}") ".yml"))
      (tags "rabbitmq"))
    (task "Ensure RabbitMQ is installed"
      (pkgng 
        (name "rabbitmq")
        (state (jinja "{{ sensu_rabbitmq_pkg_state }}")))
      (tags "rabbitmq"))))
