(playbook "debops/ansible/roles/ifupdown/tasks/main_env.yml"
  (tasks
    (task "Prepare configuration of dependent Ansible roles"
      (ansible.builtin.set_fact 
        (ifupdown__env_ferm__dependent_rules (jinja "{{ ifupdown__ferm__dependent_rules }}"))
        (ifupdown__env_kmod__dependent_load (jinja "{{ ifupdown__kmod__dependent_load }}"))
        (ifupdown__env_sysctl__dependent_parameters (jinja "{{ ifupdown__sysctl__dependent_parameters }}"))))))
