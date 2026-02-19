(playbook "debops/ansible/roles/redis_server/tasks/main_env.yml"
  (tasks
    (task "Prepare Redis role environment"
      (ansible.builtin.set_fact 
        (redis_server__env_ports (jinja "{{ lookup(\"template\", \"lookup/redis_server__env_ports.j2\") | from_yaml }}"))))))
