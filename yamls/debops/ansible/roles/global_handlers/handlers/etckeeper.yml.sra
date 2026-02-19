(playbook "debops/ansible/roles/global_handlers/handlers/etckeeper.yml"
  (tasks
    (task "Commit changes in etckeeper"
      (ansible.builtin.shell "etckeeper unclean && etckeeper commit 'Committed by Ansible \"etckeeper\" handler' || true")
      (register "global_handlers__etckeeper_register_commit")
      (changed_when "global_handlers__etckeeper_register_commit.changed | bool")
      (when "(ansible_local.etckeeper.enabled | d()) | bool"))))
