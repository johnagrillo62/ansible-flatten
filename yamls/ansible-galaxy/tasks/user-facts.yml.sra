(playbook "ansible-galaxy/tasks/user-facts.yml"
  (tasks
    (task "Get group IDs for Galaxy users"
      (getent 
        (database "passwd")
        (key (jinja "{{ item }}")))
      (with_items (list
          (jinja "{{ __galaxy_user_name }}")
          (jinja "{{ __galaxy_privsep_user_name }}")))
      (when "galaxy_group is not defined")
      (register "__galaxy_passwd_result"))
    (task "Get group names for Galaxy users"
      (getent 
        (database "group")
        (key (jinja "{{ item.ansible_facts.getent_passwd[item.invocation.module_args.key][2] }}")))
      (with_items (jinja "{{ __galaxy_passwd_result.results }}"))
      (loop_control 
        (label (jinja "{{ item.item }}")))
      (when "galaxy_group is not defined")
      (register "__galaxy_group_result"))
    (task "Set Galaxy user facts"
      (set_fact 
        (__galaxy_user_group (jinja "{{ ((galaxy_group | default({})).name | default(galaxy_group)) if galaxy_group is defined else (__galaxy_group_result.results[0].ansible_facts.getent_group.keys() | first) }}"))
        (__galaxy_privsep_user_group (jinja "{{ ((galaxy_group | default({})).name | default(galaxy_group)) if galaxy_group is defined else (__galaxy_group_result.results[1].ansible_facts.getent_group.keys() | first) }}"))))
    (task "Determine whether to restrict to group permissions"
      (set_fact 
        (__galaxy_dir_perms (jinja "{{ '0750' if __galaxy_user_group == __galaxy_privsep_user_group else '0755' }}"))))))
