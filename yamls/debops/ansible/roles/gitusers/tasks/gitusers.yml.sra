(playbook "debops/ansible/roles/gitusers/tasks/gitusers.yml"
  (tasks
    (task "Manage user accounts without UIDs"
      (ansible.builtin.user 
        (name (jinja "{{ item.name + gitusers_name_suffix }}"))
        (state (jinja "{{ item.state | default(\"present\") }}"))
        (group (jinja "{{ item.group | default(item.name + gitusers_name_suffix) }}"))
        (comment (jinja "{{ item.comment | default(\"\") }}"))
        (system (jinja "{{ item.systemuser | default(\"no\") }}"))
        (shell (jinja "{{ item.shell | default(gitusers_default_shell) }}"))
        (home (jinja "{{ item.home | default(gitusers_default_home_prefix + \"/\" + item.name + gitusers_name_suffix) }}"))
        (createhome "no"))
      (loop (jinja "{{ q(\"flattened\", gitusers_list
                           + gitusers_group_list
                           + gitusers_host_list) }}"))
      (when "((item.name is defined and item.name) and (item.uid is undefined or (item.uid is defined and not item.uid)))"))
    (task "Manage user accounts with UIDs"
      (ansible.builtin.user 
        (name (jinja "{{ item.name + gitusers_name_suffix }}"))
        (uid (jinja "{{ item.uid }}"))
        (state (jinja "{{ item.state | default(\"present\") }}"))
        (group (jinja "{{ item.group | default(item.name + gitusers_name_suffix) }}"))
        (comment (jinja "{{ item.comment | default(\"\") }}"))
        (system (jinja "{{ item.systemuser | default(\"no\") }}"))
        (shell (jinja "{{ item.shell | default(gitusers_default_shell) }}"))
        (home (jinja "{{ item.home | default(gitusers_default_home_prefix + \"/\" + item.name + gitusers_name_suffix) }}"))
        (createhome "no"))
      (loop (jinja "{{ q(\"flattened\", gitusers_list
                           + gitusers_group_list
                           + gitusers_host_list) }}"))
      (when "((item.name is defined and item.name) and (item.uid is defined and item.uid))"))
    (task "Manage user default groups"
      (ansible.builtin.user 
        (name (jinja "{{ item.name + gitusers_name_suffix }}"))
        (state (jinja "{{ item.state | default(\"present\") }}"))
        (groups (jinja "{{ gitusers_default_groups_list | join(\",\") }}"))
        (append (jinja "{{ gitusers_default_groups_append }}")))
      (loop (jinja "{{ q(\"flattened\", gitusers_list
                           + gitusers_group_list
                           + gitusers_host_list) }}"))
      (when "((item.name is defined and item.name) and (gitusers_default_groups_list is defined and gitusers_default_groups_list))"))
    (task "Manage user custom groups"
      (ansible.builtin.user 
        (name (jinja "{{ item.name + gitusers_name_suffix }}"))
        (state (jinja "{{ item.state | default(\"present\") }}"))
        (groups (jinja "{{ item.groups | join(\",\") }}"))
        (append (jinja "{{ item.append | default(\"yes\") }}")))
      (loop (jinja "{{ q(\"flattened\", gitusers_list
                           + gitusers_group_list
                           + gitusers_host_list) }}"))
      (when "((item.name is defined and item.name) and (item.groups is defined and item.groups))"))
    (task "Enforce home directories permissions"
      (ansible.builtin.file 
        (state "directory")
        (path (jinja "{{ item.home | default(gitusers_default_home_prefix + \"/\" + item.name + gitusers_name_suffix) }}"))
        (owner (jinja "{{ item.name + gitusers_name_suffix }}"))
        (group (jinja "{{ item.group | default(item.name + gitusers_name_suffix) }}"))
        (mode (jinja "{{ gitusers_default_home_mode }}")))
      (loop (jinja "{{ q(\"flattened\", gitusers_list
                           + gitusers_group_list
                           + gitusers_host_list) }}"))
      (when "((item.name is defined and item.name) and (item.state is undefined or (item.state is defined and item.state != 'absent')))"))))
