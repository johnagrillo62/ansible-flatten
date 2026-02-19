(playbook "debops/ansible/roles/kibana/tasks/main_env.yml"
  (tasks
    (task "Prepare debops.kibana environment"
      (ansible.builtin.set_fact 
        (kibana__secret__directories (jinja "{{ lookup(\"template\", \"lookup/kibana__secret__directories.j2\") | from_yaml }}"))))))
