(playbook "debops/ansible/roles/debops_legacy/tasks/main.yml"
  (tasks
    (task "Import custom Ansible plugins"
      (ansible.builtin.import_role 
        (name "ansible_plugins")))
    (task "Remove legacy diversions"
      (debops.debops.dpkg_divert 
        (path (jinja "{{ item.name }}"))
        (divert (jinja "{{ item.diversion | d(item.name + \".dpkg-divert\") }}"))
        (state "absent")
        (delete "True"))
      (with_items (jinja "{{ debops_legacy__remove_combined_diversions | debops.debops.parse_kv_items }}"))
      (when "debops_legacy__enabled | bool and item.state | d('present') == 'absent'"))
    (task "Remove legacy packages"
      (ansible.builtin.package 
        (name (jinja "{{ item.name }}"))
        (state "absent"))
      (with_items (jinja "{{ debops_legacy__remove_combined_packages | debops.debops.parse_kv_items }}"))
      (when "debops_legacy__enabled | bool and item.state | d('present') == 'absent'"))
    (task "Remove legacy files and directories"
      (ansible.builtin.file 
        (path (jinja "{{ item.name }}"))
        (state "absent"))
      (with_items (jinja "{{ debops_legacy__remove_combined_files | debops.debops.parse_kv_items }}"))
      (when "debops_legacy__enabled | bool and item.state | d('present') == 'absent'"))))
