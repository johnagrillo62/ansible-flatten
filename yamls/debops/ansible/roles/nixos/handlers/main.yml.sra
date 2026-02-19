(playbook "debops/ansible/roles/nixos/handlers/main.yml"
  (tasks
    (task "Rebuild NixOS system"
      (ansible.builtin.command (jinja "{{ nixos__rebuild_command }}"))
      (register "nixos__register_rebuild_command")
      (changed_when "nixos__register_rebuild_command.stdout != ''")
      (when "nixos__rebuild | bool and not ansible_check_mode | bool"))))
