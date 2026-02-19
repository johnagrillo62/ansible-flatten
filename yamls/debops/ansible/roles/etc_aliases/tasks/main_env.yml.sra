(playbook "debops/ansible/roles/etc_aliases/tasks/main_env.yml"
  (tasks
    (task "Prepare debops.etc_aliases environment"
      (ansible.builtin.set_fact 
        (etc_aliases__secret__directories (jinja "{{ lookup(\"template\", \"lookup/etc_aliases__secret__directories.j2\")
                                          | from_yaml }}"))))))
