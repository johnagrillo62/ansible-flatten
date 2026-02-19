(playbook "debops/ansible/roles/extrepo/tasks/main.yml"
  (tasks
    (task "Import custom Ansible plugins"
      (ansible.builtin.import_role 
        (name "ansible_plugins")))
    (task "Import DebOps global handlers"
      (ansible.builtin.import_role 
        (name "global_handlers")))
    (task "Install required packages"
      (ansible.builtin.package 
        (name (jinja "{{ q(\"flattened\", (extrepo__base_packages
                              + extrepo__packages)) }}"))
        (state "present"))
      (register "extrepo__register_packages")
      (until "extrepo__register_packages is succeeded")
      (when "extrepo__enabled | bool"))
    (task "Make sure that Ansible local facts directory exists"
      (ansible.builtin.file 
        (path "/etc/ansible/facts.d")
        (state "directory")
        (mode "0755")))
    (task "Save extrepo local facts"
      (ansible.builtin.template 
        (src "etc/ansible/facts.d/extrepo.fact.j2")
        (dest "/etc/ansible/facts.d/extrepo.fact")
        (mode "0755"))
      (notify (list
          "Refresh host facts"))
      (tags (list
          "meta::facts")))
    (task "Update Ansible facts if they were modified"
      (ansible.builtin.meta "flush_handlers"))
    (task "Divert original extrepo configuration"
      (debops.debops.dpkg_divert 
        (path "/etc/extrepo/config.yaml")
        (state "present"))
      (when "extrepo__enabled | bool and ansible_pkg_mgr == 'apt'"))
    (task "Generate extrepo configuration file"
      (ansible.builtin.template 
        (src "etc/extrepo/config.yaml.j2")
        (dest "/etc/extrepo/config.yaml")
        (mode "0644"))
      (register "extrepo__register_config")
      (when "extrepo__enabled | bool"))
    (task "Update external APT sources if required"
      (ansible.builtin.command "extrepo update " (jinja "{{ item.name }}"))
      (loop (jinja "{{ q(\"flattened\", extrepo__combined_sources) | debops.debops.parse_kv_config }}"))
      (loop_control 
        (label (jinja "{{ {\"name\": item.name, \"state\": item.state} }}")))
      (register "extrepo__register_updated_sources")
      (changed_when "extrepo__register_updated_sources.changed | bool")
      (when "extrepo__enabled | bool and item.name in ansible_local.extrepo.sources | d() and item.state | d('present') not in ['absent', 'init', 'ignore'] and extrepo__register_config is changed"))
    (task "Remove external APT sources when requested"
      (ansible.builtin.file 
        (path (jinja "{{ \"/etc/apt/sources.list.d/extrepo_\" + item.name + \".sources\" }}"))
        (state "absent"))
      (loop (jinja "{{ q(\"flattened\", extrepo__combined_sources) | debops.debops.parse_kv_config }}"))
      (loop_control 
        (label (jinja "{{ {\"name\": item.name, \"state\": item.state} }}")))
      (register "extrepo__register_removed_sources")
      (changed_when "extrepo__register_removed_sources.changed | bool")
      (when "extrepo__enabled | bool and item.name and item.state | d('present') == 'absent'"))
    (task "Enable external APT sources"
      (ansible.builtin.command "extrepo enable " (jinja "{{ item.name }}"))
      (loop (jinja "{{ q(\"flattened\", extrepo__combined_sources) | debops.debops.parse_kv_config }}"))
      (loop_control 
        (label (jinja "{{ {\"name\": item.name, \"state\": item.state} }}")))
      (register "extrepo__register_enabled_sources")
      (changed_when "extrepo__register_enabled_sources.changed | bool")
      (when "extrepo__enabled | bool and item.name not in ansible_local.extrepo.sources | d() and item.state | d('present') not in ['absent', 'init', 'ignore']"))
    (task "Update APT cache if required"
      (ansible.builtin.apt 
        (update_cache "True"))
      (notify (list
          "Refresh host facts"))
      (register "extrepo__register_apt_cache")
      (until "extrepo__register_apt_cache is succeeded")
      (when "(extrepo__enabled | bool and (extrepo__register_updated_sources is changed or extrepo__register_removed_sources is changed or extrepo__register_enabled_sources is changed))"))
    (task "Update Ansible facts if APT cache was modified"
      (ansible.builtin.meta "flush_handlers"))))
