(playbook "debops/ansible/roles/postconf/tasks/main_env.yml"
  (tasks
    (task "Prepare postconf environment"
      (ansible.builtin.set_fact 
        (postconf__env_capabilities (jinja "{{ lookup(\"template\", \"lookup/postconf__env_capabilities.j2\") }}"))))))
