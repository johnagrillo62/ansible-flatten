(playbook "debops/ansible/roles/gitusers/tasks/sshkeys.yml"
  (tasks
    (task "Configure authorized SSH keys for users"
      (ansible.posix.authorized_key 
        (key (jinja "{{ \"\\n\".join(item.sshkeys) | string }}"))
        (state "present")
        (user (jinja "{{ item.name + gitusers_name_suffix }}")))
      (loop (jinja "{{ q(\"flattened\", gitusers_list
                           + gitusers_group_list
                           + gitusers_host_list) }}"))
      (when "((item.name is defined and item.name) and (item.state is undefined or (item.state is defined and item.state != 'absent')) and (item.sshkeys is defined and item.sshkeys))"))
    (task "Remove ~/.ssh/authorized_keys from user account if disabled"
      (ansible.builtin.file 
        (dest (jinja "{{ item.home | default(gitusers_default_home_prefix + \"/\"
                                  + item.name + gitusers_name_suffix) }}") "/.ssh/authorized_keys")
        (state "absent"))
      (loop (jinja "{{ q(\"flattened\", gitusers_list
                           + gitusers_group_list
                           + gitusers_host_list) }}"))
      (when "((item.name is defined and item.name) and (item.state is undefined or (item.state is defined and item.state != 'absent')) and (item.sshkeys is defined and not item.sshkeys | bool))"))))
