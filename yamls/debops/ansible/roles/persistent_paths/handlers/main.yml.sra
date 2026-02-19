(playbook "debops/ansible/roles/persistent_paths/handlers/main.yml"
  (tasks
    (task "Run bind-dirs"
      (ansible.builtin.command (jinja "{{ persistent_paths__qubes_os_handler }}"))
      (register "persistent_paths__register_bind_dirs")
      (changed_when "persistent_paths__register_bind_dirs.changed | bool"))))
