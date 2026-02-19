(playbook "debops/ansible/roles/yadm/tasks/manage_dotfiles.yml"
  (tasks
    (task "Clone dotfiles repo " (jinja "{{ dotfile.name }}")
      (ansible.builtin.git 
        (repo (jinja "{{ item_git.repo | d(item_git) }}"))
        (dest (jinja "{{ yadm__dotfiles_root + \"/\"
              + (item_git.repo | d(item_git)).split(\"://\")[1] | regex_replace(\"\\.git$\", \"\")
              + \".git\" }}"))
        (version (jinja "{{ item_git.version | d(\"master\") }}"))
        (verify_commit (jinja "{{ True if dotfile.gpg | d() else omit }}"))
        (bare "True"))
      (loop (jinja "{{ q(\"flattened\", dotfile.git) }}"))
      (loop_control 
        (loop_var "item_git"))
      (when "dotfile.git | d() and dotfile.state | d('present') not in ['absent', 'ignore'] and not ansible_check_mode"))
    (task "Remove dotfiles repo " (jinja "{{ dotfile.name }}")
      (ansible.builtin.file 
        (dest (jinja "{{ (yadm__dotfiles_root + \"/\"
               + (item_git.repo | d(item_git)).split(\"://\")[1] | regex_replace(\"\\.git$\", \"\")
               + \".git\") | dirname }}"))
        (state "absent"))
      (loop (jinja "{{ q(\"flattened\", dotfile.git) }}"))
      (loop_control 
        (loop_var "item_git"))
      (when "dotfile.git | d() and dotfile.state | d('present') == 'absent'"))
    (task "Manage the cloned dotfiles repo in system-wide /etc/gitconfig"
      (community.general.git_config 
        (scope "system")
        (name "safe.directory")
        (value (jinja "{{ yadm__dotfiles_root + \"/\"
              + (item_git.repo | d(item_git)).split(\"://\")[1] | regex_replace(\"\\.git$\", \"\")
              + \".git\" }}"))
        (add_mode "add")
        (state (jinja "{{ \"present\"
               if (dotfile.git | d() and (dotfile.state | d(\"present\")) == \"present\")
               else \"absent\" }}")))
      (loop (jinja "{{ q(\"flattened\", dotfile.git) }}"))
      (loop_control 
        (loop_var "item_git")))))
