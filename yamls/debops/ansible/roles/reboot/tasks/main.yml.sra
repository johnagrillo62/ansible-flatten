(playbook "debops/ansible/roles/reboot/tasks/main.yml"
  (tasks
    (task "Check if reboot is required"
      (ansible.builtin.stat 
        (path "/var/run/reboot-required")
        (get_checksum "False"))
      (register "reboot__register_required"))
    (task "Reboot DebOps hosts if needed or requested"
      (ansible.builtin.reboot 
        (boot_time_command (jinja "{{ reboot__boot_time_command }}"))
        (search_paths (jinja "{{ (reboot__default_search_paths + reboot__search_paths) | flatten }}"))
        (reboot_timeout (jinja "{{ reboot__timeout }}")))
      (when "reboot__register_required.stat.exists | bool or reboot__force | bool"))))
