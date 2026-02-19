(playbook "debops/ansible/roles/gitusers/tasks/groups_present.yml"
  (tasks
    (task "Create user groups without GIDs"
      (ansible.builtin.group 
        (name (jinja "{{ item.group | default(item.name + gitusers_name_suffix) }}"))
        (system (jinja "{{ item.systemgroup | default(\"no\") }}"))
        (state "present"))
      (loop (jinja "{{ q(\"flattened\", gitusers_list
                           + gitusers_group_list
                           + gitusers_host_list) }}"))
      (when "(((item.name is defined and item.name) and (item.gid is undefined or (item.gid is defined and not item.gid))) and (item.state is undefined or (item.state is defined and item.state != 'absent')))"))
    (task "Create user groups with GIDs"
      (ansible.builtin.group 
        (name (jinja "{{ item.group | default(item.name + gitusers_name_suffix) }}"))
        (system (jinja "{{ item.systemgroup | default(\"no\") }}"))
        (gid (jinja "{{ item.gid }}"))
        (state "present"))
      (loop (jinja "{{ q(\"flattened\", gitusers_list
                           + gitusers_group_list
                           + gitusers_host_list) }}"))
      (when "((item.name is defined and item.name) and (item.gid is defined and item.gid) and (item.state is undefined or (item.state is defined and item.state != 'absent')))"))))
