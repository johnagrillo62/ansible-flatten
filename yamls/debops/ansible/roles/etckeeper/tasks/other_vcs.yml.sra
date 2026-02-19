(playbook "debops/ansible/roles/etckeeper/tasks/other_vcs.yml"
  (tasks
    (task "Set user, email for the bzr repository"
      (ansible.builtin.command "etckeeper vcs whoami '" (jinja "{{ etckeeper__vcs_user }}") " <" (jinja "{{ etckeeper__vcs_email }}") ">'")
      (register "etckeeper__register_bzr_owner")
      (changed_when "etckeeper__register_bzr_owner.changed | bool")
      (when "(etckeeper__vcs == 'bzr' and etckeeper__vcs_user | d() and etckeeper__vcs_email | d())"))
    (task "Set user, email for the darcs repository"
      (ansible.builtin.command "etckeeper vcs setpref author '" (jinja "{{ etckeeper__vcs_user }}") " <" (jinja "{{ etckeeper__vcs_email }}") ">'")
      (register "etckeeper__register_darcs_owner")
      (changed_when "etckeeper__register_darcs_owner.changed | bool")
      (when "(etckeeper__vcs == 'darcs' and etckeeper__vcs_user | d() and etckeeper__vcs_email | d())"))
    (task "Set user, email for the hg repository"
      (ansible.builtin.command "etckeeper vcs --config 'ui.username=" (jinja "{{ etckeeper__vcs_user }}") " <" (jinja "{{ etckeeper__vcs_email }}") ">'")
      (register "etckeeper__register_hg_owner")
      (changed_when "etckeeper__register_hg_owner.changed | bool")
      (when "(etckeeper__vcs == 'hg' and etckeeper__vcs_user | d() and etckeeper__vcs_email | d())"))))
