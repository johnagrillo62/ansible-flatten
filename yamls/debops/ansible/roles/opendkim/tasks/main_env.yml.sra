(playbook "debops/ansible/roles/opendkim/tasks/main_env.yml"
  (tasks
    (task "Prepare OpenDKIM environment"
      (ansible.builtin.set_fact 
        (opendkim__secret__directories (jinja "{{ lookup(\"template\", \"lookup/opendkim__secret__directories.j2\") | from_yaml }}"))))))
