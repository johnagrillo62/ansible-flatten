(playbook "debops/ansible/roles/icinga/tasks/main_env.yml"
  (tasks
    (task "Prepare Icinga environment"
      (ansible.builtin.set_fact 
        (icinga__secret__directories (jinja "{{ lookup(\"template\", \"lookup/icinga__secret__directories.j2\") | from_yaml }}"))))))
