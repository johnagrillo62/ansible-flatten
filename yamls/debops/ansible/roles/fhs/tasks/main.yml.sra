(playbook "debops/ansible/roles/fhs/tasks/main.yml"
  (tasks
    (task "Import custom Ansible plugins"
      (ansible.builtin.import_role 
        (name "ansible_plugins")))
    (task "Import DebOps global handlers"
      (ansible.builtin.import_role 
        (name "global_handlers")))
    (task "Create base directory hierarchy"
      (ansible.builtin.file 
        (path (jinja "{{ hostvars[inventory_hostname][\"ansible_local\"][\"fhs\"][item.name] | d(item.path) }}"))
        (state "directory")
        (mode (jinja "{{ item.mode | d(\"0755\") }}")))
      (loop (jinja "{{ fhs__combined_directories | debops.debops.parse_kv_items }}"))
      (loop_control 
        (label (jinja "{{ {item.name: (hostvars[inventory_hostname][\"ansible_local\"][\"fhs\"][item.name] | d(item.path))} }}")))
      (when "(fhs__enabled | bool and item.state | d('present') != 'absent' and (hostvars[inventory_hostname][\"ansible_local\"][\"fhs\"][item.name] | d(item.path)).startswith('/'))")
      (tags (list
          "meta::facts")))
    (task "Save fhs local facts"
      (ansible.builtin.template 
        (src "etc/ansible/facts.d/fhs.fact.j2")
        (dest "/etc/ansible/facts.d/fhs.fact")
        (mode "0755"))
      (notify (list
          "Refresh host facts"))
      (when "fhs__enabled | bool")
      (tags (list
          "meta::facts")))
    (task "Update Ansible facts if they were modified"
      (ansible.builtin.meta "flush_handlers"))))
