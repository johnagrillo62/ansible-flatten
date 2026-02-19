(playbook "debops/ansible/roles/freeradius/tasks/main.yml"
  (tasks
    (task "Import custom Ansible plugins"
      (ansible.builtin.import_role 
        (name "ansible_plugins")))
    (task "Import DebOps global handlers"
      (ansible.builtin.import_role 
        (name "global_handlers")))
    (task "Import DebOps secret role"
      (ansible.builtin.import_role 
        (name "secret")))
    (task "Install FreeRADIUS packages"
      (ansible.builtin.package 
        (name (jinja "{{ item }}"))
        (state "present"))
      (loop (jinja "{{ q(\"flattened\", freeradius__base_packages
                           + freeradius__packages) }}"))
      (register "freeradius__register_packages")
      (until "freeradius__register_packages is succeeded"))
    (task "Enable FreeRADIUS service in systemd to start at boot time"
      (ansible.builtin.systemd 
        (name "freeradius.service")
        (enabled "True"))
      (when "ansible_service_mgr == 'systemd'"))
    (task "Make sure that Ansible local facts directory exists"
      (ansible.builtin.file 
        (path "/etc/ansible/facts.d")
        (state "directory")
        (owner "root")
        (group "root")
        (mode "0755")))
    (task "Save FreeRADIUS local facts"
      (ansible.builtin.template 
        (src "etc/ansible/facts.d/freeradius.fact.j2")
        (dest "/etc/ansible/facts.d/freeradius.fact")
        (owner "root")
        (group "root")
        (mode "0755"))
      (notify (list
          "Refresh host facts"))
      (tags (list
          "meta::facts")))
    (task "Update Ansible facts if they were modified"
      (ansible.builtin.meta "flush_handlers"))
    (task "Get list of FreeRADIUS Conffiles"
      (ansible.builtin.command "cat /var/lib/dpkg/info/freeradius-config.conffiles")
      (register "freeradius__register_conffiles")
      (changed_when "False")
      (check_mode "False"))
    (task "Add/remove diversion of FreeRADIUS configuration files"
      (debops.debops.dpkg_divert 
        (path (jinja "{{ freeradius__var_divert_path }}"))
        (divert (jinja "{{ freeradius__var_divert_divert }}"))
        (state (jinja "{{ item.state | d(\"present\") }}"))
        (delete "True"))
      (vars 
        (freeradius__var_divert_path (jinja "{{ freeradius__conf_base_path + \"/\" + (item.filename | d(item.name)) }}"))
        (freeradius__var_divert_divert (jinja "{{ freeradius__conf_base_path + \"/\"
                                       + (item.divert_filename
                                          | d((((item.filename | d(item.name)) | dirname + \"/.\")
                                               if ((item.filename | d(item.name)) | dirname) else \".\")
                                              + (item.filename | d(item.name)) | basename + \".dpkg-divert\")) }}")))
      (loop (jinja "{{ freeradius__combined_configuration | debops.debops.parse_kv_items }}"))
      (loop_control 
        (label (jinja "{{ {\"path\": freeradius__var_divert_path,
                \"divert\": freeradius__var_divert_divert,
                \"state\": item.state | d(\"present\")} }}")))
      (notify (list
          "Check freeradius configuration and restart"))
      (when "(item.name | d() and item.divert | d(False) | bool and item.state | d('present') in ['present', 'absent'])")
      (no_log (jinja "{{ debops__no_log | d(item.no_log) | d(False) }}")))
    (task "Create missing configuration directories"
      (ansible.builtin.file 
        (path (jinja "{{ (freeradius__conf_base_path + \"/\" + (item.filename | d(item.name))) | dirname }}"))
        (state "directory")
        (owner (jinja "{{ freeradius__user }}"))
        (group (jinja "{{ freeradius__group }}"))
        (mode "0755"))
      (with_items (jinja "{{ freeradius__combined_configuration | debops.debops.parse_kv_items }}"))
      (loop_control 
        (label (jinja "{{ {\"path\": ((freeradius__conf_base_path + \"/\" + (item.filename | d(item.name))) | dirname)} }}")))
      (when "(item.name | d() and item.state | d('present') not in ['absent', 'ignore', 'init'] and (item.link_src | d() or item.options | d() or item.raw | d()))")
      (no_log (jinja "{{ debops__no_log | d(item.no_log) | d(False) }}")))
    (task "Generate FreeRADIUS configuration files"
      (ansible.builtin.template 
        (src "etc/freeradius/template.conf.j2")
        (dest (jinja "{{ freeradius__conf_base_path + \"/\" + (item.filename | d(item.name)) }}"))
        (owner (jinja "{{ item.owner | d(freeradius__user) }}"))
        (group (jinja "{{ item.group | d(freeradius__group) }}"))
        (mode (jinja "{{ item.mode | d(\"0640\") }}")))
      (with_items (jinja "{{ freeradius__combined_configuration | debops.debops.parse_kv_items }}"))
      (notify (list
          "Check freeradius configuration and restart"))
      (when "(item.name | d() and item.state | d('present') not in ['absent', 'ignore', 'init'] and not item.link_src | d() and (item.options | d() or item.raw | d()))")
      (no_log (jinja "{{ debops__no_log | d(item.no_log) | d(False) }}")))
    (task "Create configuration file symlinks"
      (ansible.builtin.file 
        (dest (jinja "{{ freeradius__conf_base_path + \"/\" + (item.filename | d(item.name)) }}"))
        (src (jinja "{{ item.link_src }}"))
        (state "link")
        (owner (jinja "{{ item.owner | d(freeradius__user) }}"))
        (group (jinja "{{ item.group | d(freeradius__group) }}"))
        (mode (jinja "{{ item.mode | d(\"0640\") }}")))
      (with_items (jinja "{{ freeradius__combined_configuration | debops.debops.parse_kv_items }}"))
      (notify (list
          "Check freeradius configuration and restart"))
      (when "(item.name | d() and item.state | d('present') not in ['absent', 'ignore', 'init'] and item.link_src | d())")
      (no_log (jinja "{{ debops__no_log | d(item.no_log) | d(False) }}")))
    (task "Remove FreeRADIUS configuration files"
      (ansible.builtin.file 
        (dest (jinja "{{ freeradius__conf_base_path + \"/\" + (item.filename | d(item.name)) }}"))
        (state "absent"))
      (with_items (jinja "{{ freeradius__combined_configuration | debops.debops.parse_kv_items }}"))
      (notify (list
          "Check freeradius configuration and restart"))
      (when "(item.name | d() and not item.divert | d(False) | bool and item.state | d('present') == 'absent')")
      (no_log (jinja "{{ debops__no_log | d(item.no_log) | d(False) }}")))))
