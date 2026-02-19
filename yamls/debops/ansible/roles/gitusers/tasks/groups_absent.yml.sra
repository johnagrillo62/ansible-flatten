(playbook "debops/ansible/roles/gitusers/tasks/groups_absent.yml"
  (tasks
    (task "Remove user groups if requested"
      (ansible.builtin.group 
        (name (jinja "{{ item.group | default(item.name + gitusers_name_suffix) }}"))
        (state "absent"))
      (loop (jinja "{{ q(\"flattened\", gitusers_list
                           + gitusers_group_list
                           + gitusers_host_list) }}"))
      (when "(item.name is defined and (item.state is defined and item.state == 'absent'))"))))
