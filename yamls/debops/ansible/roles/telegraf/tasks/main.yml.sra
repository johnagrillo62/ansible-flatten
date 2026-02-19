(playbook "debops/ansible/roles/telegraf/tasks/main.yml"
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
    (task "Add Telegraf UNIX account to required groups"
      (ansible.builtin.user 
        (name "telegraf")
        (groups (jinja "{{ telegraf__additional_groups | flatten | join(\",\") }}"))
        (state "present")
        (append "True"))
      (notify (list
          "Check telegraf and restart")))
    (task "Configure Telegraf instance leading file"
      (ansible.builtin.template 
        (src "etc/telegraf/telegraf.conf.j2")
        (dest "/etc/telegraf/telegraf.conf")
        (owner "root")
        (group "root")
        (mode "0644"))
      (notify (list
          "Check telegraf and restart")))
    (task "Remove plugins configuration if requested"
      (ansible.builtin.file 
        (path "/etc/telegraf/telegraf.d/" (jinja "{{ item.name }}") ".conf")
        (state "absent"))
      (loop (jinja "{{ telegraf__combined_plugins | debops.debops.parse_kv_items }}"))
      (loop_control 
        (label (jinja "{{ {\"name\": item.name, \"state\": item.state | d(\"present\")} }}")))
      (when "item.state | d('present') == 'absent' and item.config | d()")
      (notify (list
          "Check telegraf and restart")))
    (task "Find plugins which are in filesystem"
      (ansible.builtin.find 
        (paths "/etc/telegraf/telegraf.d")
        (patterns "*.conf"))
      (register "telegraf__register_existing_plugins_filenames"))
    (task "Backup and disactivate plugins unexisting in desired configuration"
      (ansible.builtin.command 
        (cmd "mv -f '" (jinja "{{ item.path | quote }}") "' '" (jinja "{{ item.path | quote }}") ".inactive'")
        (removes (jinja "{{ item.path }}")))
      (loop (jinja "{{ telegraf__register_existing_plugins_filenames.files }}"))
      (loop_control 
        (label (jinja "{{ {\"path\": item.path} }}")))
      (when "item.path | basename | splitext | first not in telegraf__combined_plugins | debops.debops.parse_kv_items | map(attribute=\"name\")")
      (notify (list
          "Check telegraf and restart")))
    (task "Configure plugins"
      (ansible.builtin.template 
        (src "etc/telegraf/telegraf.d/plugin.conf.j2")
        (dest "/etc/telegraf/telegraf.d/" (jinja "{{ item.name }}") ".conf")
        (owner "root")
        (group "telegraf")
        (mode "0640"))
      (loop (jinja "{{ telegraf__combined_plugins | debops.debops.parse_kv_items }}"))
      (loop_control 
        (label (jinja "{{ {\"name\": item.name, \"state\": item.state | d(\"present\")} }}")))
      (when "(item.state | d('present') not in ['absent', 'ignore'] and (item.config | d() or item.raw | d()))")
      (no_log (jinja "{{ debops__no_log | d(True) }}"))
      (notify (list
          "Check telegraf and restart")))
    (task "Make sure that Ansible local facts directory exists"
      (ansible.builtin.file 
        (path "/etc/ansible/facts.d")
        (state "directory")
        (mode "0755")))
    (task "Save Telegraf instance local facts"
      (ansible.builtin.template 
        (src "etc/ansible/facts.d/telegraf.fact.j2")
        (dest "/etc/ansible/facts.d/telegraf.fact")
        (owner "root")
        (group "root")
        (mode "0755"))
      (notify (list
          "Refresh host facts"))
      (tags (list
          "meta::facts")))
    (task "Re-read local facts if they have been modified"
      (ansible.builtin.meta "flush_handlers"))))
