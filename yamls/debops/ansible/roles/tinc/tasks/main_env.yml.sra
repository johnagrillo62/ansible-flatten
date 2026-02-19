(playbook "debops/ansible/roles/tinc/tasks/main_env.yml"
  (tasks
    (task "Prepare debops.tinc environment"
      (ansible.builtin.set_fact 
        (tinc__env_secret__directories (jinja "{{ tinc__secret__directories }}"))
        (tinc__env_etc_services__dependent_list (jinja "{{ tinc__etc_services__dependent_list }}"))
        (tinc__env_ferm__dependent_rules (jinja "{{ tinc__ferm__dependent_rules }}"))))))
