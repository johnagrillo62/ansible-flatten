(playbook "debops/ansible/roles/system_groups/tasks/main.yml"
  (tasks
    (task "Import custom Ansible plugins"
      (ansible.builtin.import_role 
        (name "ansible_plugins")))
    (task "Import DebOps global handlers"
      (ansible.builtin.import_role 
        (name "global_handlers")))
    (task "Create a fact that knows the Ansible connection type"
      (ansible.builtin.set_fact 
        (system_groups__fact_ansible_connection (jinja "{{ ansible_connection }}")))
      (tags (list
          "meta::facts")))
    (task "Ensure that requested UNIX system groups exist"
      (ansible.builtin.group 
        (name (jinja "{{ item.name }}"))
        (gid (jinja "{{ item.gid | d(omit) }}"))
        (state "present")
        (system (jinja "{{ item.system | d(True) }}")))
      (with_items (jinja "{{ system_groups__combined_list | debops.debops.parse_kv_items }}"))
      (when "system_groups__enabled | bool and item.name | d() and item.state | d('present') not in ['init', 'absent', 'ignore']"))
    (task "Get list of existing UNIX accounts"
      (ansible.builtin.getent 
        (database "passwd"))
      (when "system_groups__enabled | bool"))
    (task "Add specified UNIX accounts to system groups if present"
      (ansible.builtin.user 
        (name (jinja "{{ item.name }}"))
        (append (jinja "{{ item.append }}"))
        (groups (jinja "{{ item.groups }}"))
        (create_home "False"))
      (throttle (jinja "{{ system_groups__throttle }}"))
      (with_items (jinja "{{ lookup(\"template\", \"lookup/system_groups_members.j2\") | from_yaml }}"))
      (when "system_groups__enabled | bool"))
    (task "Remove sudo configuration if not specified"
      (ansible.builtin.file 
        (path "/etc/sudoers.d/" (jinja "{{ item.sudoers_filename | d(\"system_groups-\" + item.name) }}"))
        (state "absent"))
      (with_items (jinja "{{ system_groups__combined_list | debops.debops.parse_kv_items }}"))
      (when "system_groups__enabled | bool and system_groups__sudo_enabled | bool and item.name | d() and item.state | d('present') not in ['init', 'absent', 'ignore'] and not item.sudoers | d()"))
    (task "Configure sudo for UNIX system groups"
      (ansible.builtin.template 
        (src "etc/sudoers.d/system_groups.j2")
        (dest "/etc/sudoers.d/" (jinja "{{ item.sudoers_filename | d(\"system_groups-\" + item.name) }}"))
        (owner "root")
        (group "root")
        (mode "0440")
        (validate "/usr/sbin/visudo -cf %s"))
      (with_items (jinja "{{ system_groups__combined_list | debops.debops.parse_kv_items }}"))
      (when "system_groups__enabled | bool and system_groups__sudo_enabled | bool and item.name | d() and item.state | d('present') not in ['init', 'absent', 'ignore'] and item.sudoers | d()"))
    (task "Remove tmpfiles configuration if not specified"
      (ansible.builtin.file 
        (path "/etc/tmpfiles.d/" (jinja "{{ item.tmpfiles_filename | d(\"system_groups-\" + item.name + \".conf\") }}"))
        (state "absent"))
      (with_items (jinja "{{ system_groups__combined_list | debops.debops.parse_kv_items }}"))
      (when "system_groups__enabled | bool and ansible_service_mgr == 'systemd' and item.name | d() and item.state | d('present') not in ['init', 'absent', 'ignore'] and not item.tmpfiles | d()"))
    (task "Generate tmpfiles configuration for UNIX system groups"
      (ansible.builtin.template 
        (src "etc/tmpfiles.d/system_groups.conf.j2")
        (dest "/etc/tmpfiles.d/" (jinja "{{ item.tmpfiles_filename | d(\"system_groups-\" + item.name + \".conf\") }}"))
        (owner "root")
        (group "root")
        (mode "0644"))
      (with_items (jinja "{{ system_groups__combined_list | debops.debops.parse_kv_items }}"))
      (notify (list
          "Create temporary files"))
      (when "system_groups__enabled | bool and ansible_service_mgr == 'systemd' and item.name | d() and item.state | d('present') not in ['init', 'absent', 'ignore'] and item.tmpfiles | d()"))
    (task "Make sure that Ansible local facts directory exists"
      (ansible.builtin.file 
        (path "/etc/ansible/facts.d")
        (state "directory")
        (owner "root")
        (group "root")
        (mode "0755")))
    (task "Save system groups local facts"
      (ansible.builtin.template 
        (src "etc/ansible/facts.d/system_groups.fact.j2")
        (dest "/etc/ansible/facts.d/system_groups.fact")
        (owner "root")
        (group "root")
        (mode "0755"))
      (notify (list
          "Refresh host facts"))
      (tags (list
          "meta::facts")))
    (task "Update Ansible facts if they were modified"
      (ansible.builtin.meta "flush_handlers"))))
