(playbook "debops/ansible/roles/monit/tasks/main.yml"
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
    (task "Install Monit packages"
      (ansible.builtin.package 
        (name (jinja "{{ q(\"flattened\", (monit__base_packages
                              + monit__packages)) }}"))
        (state "present"))
      (register "monit__register_packages")
      (until "monit__register_packages is succeeded"))
    (task "Remove Monit configuration if requested"
      (ansible.builtin.file 
        (path "/etc/monit/conf.d/" (jinja "{{ ((item.weight | string + \"_\") if (item.weight != 0) else \"\") + item.name }}"))
        (state "absent"))
      (with_items (jinja "{{ monit__combined_config | debops.debops.parse_kv_items }}"))
      (when "item.name | d() and item.state | d('present') == 'absent'")
      (notify (list
          "Test monit and reload"))
      (no_log (jinja "{{ debops__no_log | d(True if (item.mode | d(\"0644\") == \"0600\") else False) }}")))
    (task "Generate Monit configuration"
      (ansible.builtin.template 
        (src "etc/monit/conf.d/template.j2")
        (dest "/etc/monit/conf.d/" (jinja "{{ ((item.weight | string + \"_\") if (item.weight != 0) else \"\") + item.name }}"))
        (owner "root")
        (group "root")
        (mode (jinja "{{ item.mode | d(\"0600\") }}")))
      (with_items (jinja "{{ monit__combined_config | debops.debops.parse_kv_items }}"))
      (when "item.name | d() and item.state | d('present') not in ['init', 'absent']")
      (notify (list
          "Test monit and reload"))
      (no_log (jinja "{{ debops__no_log | d(True if (item.mode | d(\"0644\") == \"0600\") else False) }}")))
    (task "Make sure Ansible local facts directory exists"
      (ansible.builtin.file 
        (dest "/etc/ansible/facts.d")
        (state "directory")
        (owner "root")
        (group "root")
        (mode "0755")))
    (task "Configure Monit local facts"
      (ansible.builtin.template 
        (src "etc/ansible/facts.d/monit.fact.j2")
        (dest "/etc/ansible/facts.d/monit.fact")
        (owner "root")
        (group "root")
        (mode "0755"))
      (notify (list
          "Refresh host facts"))
      (tags (list
          "meta::facts")))
    (task "Re-read local facts if they have been modified"
      (ansible.builtin.meta "flush_handlers"))))
