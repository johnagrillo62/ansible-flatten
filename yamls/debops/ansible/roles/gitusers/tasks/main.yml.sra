(playbook "debops/ansible/roles/gitusers/tasks/main.yml"
  (tasks
    (task "Create directory for gituser homes"
      (ansible.builtin.file 
        (path (jinja "{{ gitusers_default_home_prefix }}"))
        (state "directory")
        (owner "root")
        (group "root")
        (mode "0751")))
    (task "Configure groups"
      (ansible.builtin.include_tasks "groups_present.yml"))
    (task "Configure users"
      (ansible.builtin.include_tasks "gitusers.yml"))
    (task "Configure git-shell"
      (ansible.builtin.include_tasks "git-shell.yml"))
    (task "Configure sshkeys"
      (ansible.builtin.include_tasks "sshkeys.yml"))
    (task "Remove groups if requested"
      (ansible.builtin.include_tasks "groups_absent.yml"))))
