(playbook "debops/ansible/roles/postfix/tasks/main_env.yml"
  (tasks
    (task "Load persistent Postfix configuration"
      (ansible.builtin.set_fact 
        (postfix__env_persistent_maincf (jinja "{{ lookup(\"template\", \"lookup/postfix__env_persistent_maincf.j2\") | from_yaml }}"))
        (postfix__env_persistent_mastercf (jinja "{{ lookup(\"template\", \"lookup/postfix__env_persistent_mastercf.j2\") | from_yaml }}"))))
    (task "Prepare Postfix environment"
      (ansible.builtin.set_fact 
        (postfix__env_active_services (jinja "{{ lookup(\"template\", \"lookup/postfix__env_active_services.j2\") | from_yaml }}"))
        (postfix__secret__directories (jinja "{{ lookup(\"template\", \"lookup/postfix__secret__directories.j2\") | from_yaml }}"))))))
