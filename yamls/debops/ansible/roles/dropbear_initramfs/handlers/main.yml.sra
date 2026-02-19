(playbook "debops/ansible/roles/dropbear_initramfs/handlers/main.yml"
  (tasks
    (task "Update initramfs"
      (ansible.builtin.command "update-initramfs -u " (jinja "{{ dropbear_initramfs__update_options }}"))
      (register "dropbear_initramfs__register_update")
      (changed_when "dropbear_initramfs__register_update.changed | bool"))))
