(playbook "debops/ansible/roles/global_handlers/handlers/etc_aliases.yml"
  (tasks
    (task "Update /etc/aliases.db database"
      (ansible.builtin.command "newaliases")
      (register "global_handlers__etc_aliases_register_newaliases")
      (changed_when "global_handlers__etc_aliases_register_newaliases.changed | bool")
      (when "ansible_local | d() and ansible_local.etc_aliases | d() and ansible_local.etc_aliases.newaliases is defined and ansible_local.etc_aliases.newaliases | bool"))))
