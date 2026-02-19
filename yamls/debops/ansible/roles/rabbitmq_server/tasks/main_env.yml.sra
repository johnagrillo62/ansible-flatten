(playbook "debops/ansible/roles/rabbitmq_server/tasks/main_env.yml"
  (tasks
    (task "Prepare debops.rabbitmq_server environment"
      (ansible.builtin.set_fact 
        (rabbitmq_server__secret__directories (jinja "{{ lookup(\"template\", \"lookup/rabbitmq_server__secret__directories.j2\")
                                              | from_yaml }}"))))))
