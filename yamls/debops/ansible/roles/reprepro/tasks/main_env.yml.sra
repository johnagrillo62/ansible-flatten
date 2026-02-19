(playbook "debops/ansible/roles/reprepro/tasks/main_env.yml"
  (tasks
    (task "Prepare reprepro environment"
      (ansible.builtin.set_fact 
        (reprepro__env_nginx_servers (jinja "{{ lookup(\"template\", \"lookup/reprepro__env_nginx_servers.j2\") | from_yaml }}"))))))
