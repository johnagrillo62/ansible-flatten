(playbook "debops/ansible/roles/debconf/tasks/main.yml"
  (tasks
    (task "Import DebOps global handlers"
      (ansible.builtin.import_role 
        (name "global_handlers")))
    (task "Import DebOps secret role"
      (ansible.builtin.import_role 
        (name "secret")))
    (task "Refresh APT cache when needed"
      (ansible.builtin.apt 
        (update_cache "True")
        (cache_valid_time (jinja "{{ debconf__cache_valid_time }}")))
      (register "debconf__register_apt_update")
      (until "debconf__register_apt_update is succeeded"))
    (task "Install debconf module dependencies"
      (ansible.builtin.apt 
        (name (list
            "debconf"
            "debconf-utils"))
        (state "present"))
      (register "debconf__register_debconf_packages")
      (until "debconf__register_debconf_packages is succeeded"))
    (task "Apply requested package configuration in debconf"
      (ansible.builtin.debconf 
        (name (jinja "{{ item.name }}"))
        (question (jinja "{{ item.question | d(omit) }}"))
        (unseen (jinja "{{ item.unseen | d(omit) }}"))
        (value (jinja "{{ item.value | d(omit) }}"))
        (vtype (jinja "{{ item.vtype | d(omit) }}")))
      (loop (jinja "{{ debconf__filtered_entries }}"))
      (register "debconf__register_entries")
      (when "item.state | d('present') not in [ 'init', 'ignore' ]")
      (no_log (jinja "{{ debops__no_log | d(True
                                 if (item.vtype == \"password\")
                                 else False) }}")))
    (task "Detect packages which need to be reconfigured"
      (ansible.builtin.set_fact 
        (debconf__fact_reconfigure_packages (jinja "{{ lookup(\"template\", \"lookup/debconf__fact_reconfigure_packages.j2\",
                                                   convert_data=False) | from_yaml | flatten }}"))))
    (task "Install requested APT packages"
      (ansible.builtin.apt 
        (name (jinja "{{ q(\"flattened\", debconf__packages
                             + debconf__group_packages
                             + debconf__host_packages) }}"))
        (state (jinja "{{ debconf__apt_state }}")))
      (register "debconf__register_packages")
      (until "debconf__register_packages is succeeded"))
    (task "Reconfigure packages using debconf"
      (ansible.builtin.command "dpkg-reconfigure --frontend noninteractive " (jinja "{{ item }}"))
      (loop (jinja "{{ debconf__fact_reconfigure_packages }}"))
      (register "debconf__register_reconfigure")
      (when "item is defined")
      (changed_when "debconf__register_reconfigure.rc == 0"))
    (task "Configure alternative symlinks"
      (community.general.alternatives 
        (name (jinja "{{ item.name }}"))
        (path (jinja "{{ item.path }}"))
        (link (jinja "{{ item.link | d(omit) }}"))
        (priority (jinja "{{ item.priority | d(omit) }}")))
      (loop (jinja "{{ q(\"flattened\", debconf__default_alternatives
                           + debconf__alternatives
                           + debconf__group_alternatives
                           + debconf__host_alternatives) }}"))
      (when "item.name | d() and item.path | d()"))
    (task "Configure automatic alternatives"
      (ansible.builtin.command "update-alternatives --auto " (jinja "{{ item.name }}"))
      (register "debconf__register_alternatives")
      (loop (jinja "{{ q(\"flattened\", debconf__alternatives
                           + debconf__group_alternatives
                           + debconf__host_alternatives) }}"))
      (when "item.name | d() and not item.path | d()")
      (changed_when "debconf__register_alternatives.stdout | d()"))
    (task "Execute shell commands"
      (ansible.builtin.include_tasks "shell_commands.yml")
      (loop (jinja "{{ q(\"flattened\", debconf__combined_commands) | debops.debops.parse_kv_items }}"))
      (loop_control 
        (label (jinja "{{ {\"name\": item.name} }}")))
      (when "item.name | d() and item.state | d('present') not in [ 'absent', 'ignore' ]")
      (no_log (jinja "{{ debops__no_log | d(item.no_log) | d(False) }}"))
      (tags (list
          "role::debconf:commands")))))
