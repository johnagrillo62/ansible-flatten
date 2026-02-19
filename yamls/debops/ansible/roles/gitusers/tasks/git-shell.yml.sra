(playbook "debops/ansible/roles/gitusers/tasks/git-shell.yml"
  (tasks
    (task "Create gitusers scripts path"
      (ansible.builtin.file 
        (path (jinja "{{ gitusers_git_scripts }}"))
        (state "directory")
        (owner "root")
        (group "root")
        (mode "0755")))
    (task "Install gitusers scripts"
      (ansible.builtin.copy 
        (src "var/lib/gitusers/")
        (dest (jinja "{{ gitusers_git_scripts }}"))
        (owner "root")
        (group "root")
        (mode "0755")))
    (task "Prepare gituser environment"
      (ansible.builtin.template 
        (src "srv/gitusers/" (jinja "{{ item.1 }}") ".j2")
        (dest (jinja "{{ item.0.home | default(gitusers_default_home_prefix + \"/\"
                                    + item.0.name + gitusers_name_suffix) }}") "/." (jinja "{{ item.1 }}"))
        (owner "root")
        (group "root")
        (mode "0644"))
      (with_nested (list
          (jinja "{{ gitusers_list + gitusers_group_list + gitusers_host_list }}")
          (list
            "forward"
            "gitconfig"
            "motd")))
      (when "((item.0.name is defined and item.0.name) and (item.0.state is undefined or (item.0.state is defined and item.0.state != 'absent')))"))
    (task "Create base directory for user websites"
      (ansible.builtin.file 
        (path (jinja "{{ gitusers_default_www_prefix }}") "/" (jinja "{{ item.group | default(item.name + gitusers_name_suffix) }}"))
        (state "directory")
        (owner "root")
        (group (jinja "{{ gitusers_default_www_group }}"))
        (mode "0711"))
      (loop (jinja "{{ q(\"flattened\", gitusers_list
                           + gitusers_group_list
                           + gitusers_host_list) }}"))
      (when "((item.name is defined and item.name) and (item.state is undefined or (item.state is defined and item.state != 'absent')))"))
    (task "Create root directory for user websites"
      (ansible.builtin.file 
        (path (jinja "{{ gitusers_default_www_prefix }}") "/" (jinja "{{ item.0.group | default(item.0.name
                                                                       + gitusers_name_suffix) }}") "/" (jinja "{{ item.1 }}"))
        (state "directory")
        (owner "root")
        (group (jinja "{{ item.0.group | default(item.0.name + gitusers_name_suffix) }}"))
        (mode "02775"))
      (with_nested (list
          (jinja "{{ gitusers_list + gitusers_group_list + gitusers_host_list }}")
          (list
            "checkouts"
            "sites"
            "userdir")))
      (when "((item.0.name is defined and item.0.name) and (item.0.state is undefined or (item.0.state is defined and item.0.state != 'absent')))"))
    (task "Symlink git-shell-commands to user directories"
      (ansible.builtin.file 
        (path (jinja "{{ item.home | default(gitusers_default_home_prefix + \"/\"
                                  + item.name + gitusers_name_suffix) + \"/git-shell-commands\" }}"))
        (src (jinja "{{ gitusers_git_scripts + \"/git-shell-commands/\" }}"))
        (state "link")
        (owner "root")
        (group "root")
        (mode "0755"))
      (loop (jinja "{{ q(\"flattened\", gitusers_list
                           + gitusers_group_list
                           + gitusers_host_list) }}"))
      (when "((item.name is defined and item.name) and (item.state is undefined or (item.state is defined and item.state != 'absent')))"))))
