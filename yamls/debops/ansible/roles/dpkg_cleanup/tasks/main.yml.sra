(playbook "debops/ansible/roles/dpkg_cleanup/tasks/main.yml"
  (tasks
    (task "Ensure that the cleanup script directory exists"
      (ansible.builtin.file 
        (path (jinja "{{ dpkg_cleanup__scripts_path }}"))
        (state "directory")
        (mode "0755"))
      (when "dpkg_cleanup__enabled | bool"))
    (task "Remove cleanup scripts if requested"
      (ansible.builtin.file 
        (path (jinja "{{ dpkg_cleanup__scripts_path + \"/\" + item.name }}"))
        (state "absent"))
      (loop (jinja "{{ q(\"flattened\", dpkg_cleanup__dependent_packages) }}"))
      (loop_control 
        (label (jinja "{{ {\"package\": item.name} }}")))
      (when "dpkg_cleanup__enabled | bool and item.name | d() and item.state | d('present') == 'absent'"))
    (task "Remove cleanup hooks if requested"
      (ansible.builtin.file 
        (path (jinja "{{ dpkg_cleanup__hooks_path + \"/dpkg-cleanup-\" + item.name }}"))
        (state "absent"))
      (loop (jinja "{{ q(\"flattened\", dpkg_cleanup__dependent_packages) }}"))
      (loop_control 
        (label (jinja "{{ {\"package\": item.name} }}")))
      (when "dpkg_cleanup__enabled | bool and item.name | d() and item.state | d('present') == 'absent'"))
    (task "Generate cleanup scripts"
      (ansible.builtin.template 
        (src "usr/local/lib/dpkg-cleanup/package.j2")
        (dest (jinja "{{ dpkg_cleanup__scripts_path + \"/\" + item.name }}"))
        (mode "0755"))
      (loop (jinja "{{ q(\"flattened\", dpkg_cleanup__dependent_packages) }}"))
      (loop_control 
        (label (jinja "{{ {\"package\": item.name} }}")))
      (when "dpkg_cleanup__enabled | bool and item.name | d() and item.state | d('present') != 'absent'"))
    (task "Generate cleanup hooks"
      (ansible.builtin.template 
        (src "etc/dpkg/dpkg.cfg.d/dpkg-cleanup-package.j2")
        (dest (jinja "{{ dpkg_cleanup__hooks_path + \"/dpkg-cleanup-\" + item.name }}"))
        (mode "0644"))
      (loop (jinja "{{ q(\"flattened\", dpkg_cleanup__dependent_packages) }}"))
      (loop_control 
        (label (jinja "{{ {\"package\": item.name} }}")))
      (when "dpkg_cleanup__enabled | bool and item.name | d() and item.state | d('present') != 'absent'"))))
