(playbook "debops/ansible/roles/global_handlers/handlers/gitlab.yml"
  (tasks
    (task "Reconfigure GitLab Omnibus"
      (ansible.builtin.command "gitlab-ctl reconfigure")
      (register "global_handlers__gitlab_register_reconfigure")
      (changed_when "global_handlers__gitlab_register_reconfigure.changed | bool")
      (when "(ansible_local.gitlab.omnibus | d()) | bool"))
    (task "Restart GitLab Omnibus"
      (ansible.builtin.command "gitlab-ctl restart")
      (register "global_handlers__gitlab_register_restart")
      (changed_when "global_handlers__gitlab_register_restart.changed | bool")
      (when "(ansible_local.gitlab.omnibus | d()) | bool"))))
