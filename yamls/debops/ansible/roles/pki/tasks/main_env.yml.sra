(playbook "debops/ansible/roles/pki/tasks/main_env.yml"
  (tasks
    (task "Prepare debops.pki environment"
      (ansible.builtin.set_fact 
        (pki_env_secret_directories (jinja "{{ lookup(\"template\", \"lookup/pki_env_secret_directories.j2\") | from_yaml }}"))))))
