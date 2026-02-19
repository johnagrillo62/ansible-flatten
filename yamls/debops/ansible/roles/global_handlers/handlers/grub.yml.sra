(playbook "debops/ansible/roles/global_handlers/handlers/grub.yml"
  (tasks
    (task "Update GRUB"
      (ansible.builtin.command "update-grub")
      (register "global_handlers__grub_register_update")
      (changed_when "global_handlers__grub_register_update.changed | bool")
      (failed_when "('error' in global_handlers__grub_register_update.stderr)"))))
