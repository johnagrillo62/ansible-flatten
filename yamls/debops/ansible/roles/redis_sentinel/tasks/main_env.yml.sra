(playbook "debops/ansible/roles/redis_sentinel/tasks/main_env.yml"
  (tasks
    (task "Prepare Redis Sentinel role environment"
      (ansible.builtin.set_fact 
        (redis_sentinel__env_ports (jinja "{{ lookup(\"template\", \"lookup/redis_sentinel__env_ports.j2\") | from_yaml }}"))))))
