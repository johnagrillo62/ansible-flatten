(playbook "debops/ansible/roles/elasticsearch/tasks/main_env.yml"
  (tasks
    (task "Prepare debops.elasticsearch environment"
      (ansible.builtin.set_fact 
        (elasticsearch__secret__directories (jinja "{{ lookup(\"template\", \"lookup/elasticsearch__secret__directories.j2\")
                                            | from_yaml }}"))))))
