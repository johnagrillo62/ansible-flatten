(playbook "debops/ansible/roles/ifupdown/tasks/main.yml"
  (tasks
    (task "Import DebOps global handlers"
      (ansible.builtin.import_role 
        (name "global_handlers")))
    (task "Make sure that Ansible local facts directory exists"
      (ansible.builtin.file 
        (path "/etc/ansible/facts.d")
        (state "directory")
        (mode "0755")))
    (task "Save ifupdown local facts"
      (ansible.builtin.template 
        (src "etc/ansible/facts.d/ifupdown.fact.j2")
        (dest "/etc/ansible/facts.d/ifupdown.fact")
        (mode "0755"))
      (notify (list
          "Refresh host facts"))
      (tags (list
          "meta::facts")))
    (task "Update Ansible facts if they have been modified"
      (ansible.builtin.meta "flush_handlers"))
    (task "Install required packages"
      (ansible.builtin.package 
        (name (jinja "{{ q(\"flattened\", (ifupdown__base_packages
                              + ifupdown__dynamic_packages
                              + ifupdown__packages)) }}"))
        (state "present"))
      (register "ifupdown__register_packages")
      (until "ifupdown__register_packages is succeeded"))
    (task "Purge conflicting packages"
      (ansible.builtin.apt 
        (name (jinja "{{ q(\"flattened\", ifupdown__purge_packages) }}"))
        (state "absent")
        (purge "True")))
    (task "Create custom ifupdown systemd services"
      (ansible.builtin.include_tasks "ifup_systemd.yml")
      (when "ansible_service_mgr == 'systemd'"))
    (task "Reset network configuration on role upgrade"
      (ansible.builtin.file 
        (path "/etc/network/interfaces.config.d")
        (state "absent"))
      (when "(ansible_local | d() and ansible_local.debops_fact | d() and ansible_local.debops_fact.enabled | bool and (ansible_local.debops_fact.version is undefined or (ansible_local.debops_fact.version.ifupdown | d(\"0.0.0\") is version_compare(\"0.3.0\", \"<\"))))"))
    (task "Create configuration directories"
      (ansible.builtin.file 
        (path (jinja "{{ item }}"))
        (state "directory")
        (owner "root")
        (group "root")
        (mode "0755"))
      (with_items (list
          "/etc/network/interfaces.d"
          "/etc/network/interfaces.config.d")))
    (task "Preserve original network configuration"
      (ansible.builtin.include_tasks "divert_interfaces.yml"))
    (task "Remove network interface configuration"
      (ansible.builtin.file 
        (dest "/etc/network/interfaces.config.d/" (jinja "{{ \"%03d\" | format((ifupdown__interface_weight_map[item.value.weight_class
                                                                | d(item.value.type | d(\"default\"))] | d(\"90\")) | int
                                               + (item.value.weight | d(\"0\")) | int) }}") "_iface_" (jinja "{{ item.value.iface
                                                                                               | d(item.key) }}"))
        (state "absent"))
      (with_dict (jinja "{{ ifupdown__combined_interfaces }}"))
      (register "ifupdown__register_interfaces_removed")
      (when "item.value.state | d('present') == 'absent'"))
    (task "Generate network interface configuration"
      (ansible.builtin.template 
        (src "etc/network/interfaces.d/iface.j2")
        (dest "/etc/network/interfaces.config.d/" (jinja "{{ \"%03d\" | format((ifupdown__interface_weight_map[item.value.weight_class
                                                                | d(item.value.type | d(\"default\"))] | d(\"90\")) | int
                                               + (item.value.weight | d(\"0\")) | int) }}") "_iface_" (jinja "{{ item.value.iface
                                                                                               | d(item.key) }}"))
        (owner "root")
        (group "root")
        (mode (jinja "{{ item.value.mode | d(\"0644\") }}")))
      (with_dict (jinja "{{ ifupdown__combined_interfaces }}"))
      (register "ifupdown__register_interfaces_created")
      (when "item.value.state | d('present') not in ['absent', 'ignore']"))
    (task "Remove unknown interface configuration"
      (ansible.builtin.shell "find /etc/network/interfaces.config.d -maxdepth 1 -type f -name '*_iface_" (jinja "{{ item.item.value.iface | d(item.item.key) }}") "' ! -name '" (jinja "{{ \"%03d\" | format((ifupdown__interface_weight_map[item.item.value.weight_class
                                      | d(item.item.value.type | d(\"default\"))] | d(\"90\")) | int
                     + (item.item.value.weight | d(\"0\")) | int) }}") "_iface_" (jinja "{{ item.item.value.iface | d(item.item.key) }}") "' -exec rm -vf {} +")
      (with_items (list
          (jinja "{{ ifupdown__register_interfaces_removed.results }}")
          (jinja "{{ ifupdown__register_interfaces_created.results }}")))
      (register "ifupdown__register_iface_cleanup")
      (changed_when "ifupdown__register_iface_cleanup.changed | bool")
      (when "(item.item.key | d() and item is changed)"))
    (task "Mark modified interfaces for processing"
      (ansible.builtin.copy 
        (content (jinja "{{ (\"created\"
    if ((item.item.key | replace(':', '_') | replace('.', '_')) not in ansible_interfaces and
        (item.diff is undefined or
         (item.diff | d() and item.diff.after | d() and
          item.diff.after_header | d() and
          item.diff.after_header == \"dynamically generated\")))
    else (\"removed\"
          if (item.diff | d() and item.diff.after | d() and
              item.diff.after.state | d() and
              item.diff.after.state == \"absent\")
          else \"changed\")) }}") "
")
        (dest (jinja "{{ \"/run/network/debops-ifupdown-reconfigure,\" +
              (\"%03d\" | format(((ifupdown__interface_weight_map[item.item.value.weight_class
                                 | d(item.item.value.type | d(\"default\"))]
                                 | d(ifupdown__interface_weight_map[\"default\"] | d(\"90\"))) | int
               + (item.item.value.weight | d(\"0\")) | int))) | string + \",\"
               + (item.item.value.iface | d(item.item.key)) }}"))
        (owner "root")
        (group "root")
        (mode "0644"))
      (with_items (list
          (jinja "{{ ifupdown__register_interfaces_removed.results }}")
          (jinja "{{ ifupdown__register_interfaces_created.results }}")))
      (notify (list
          "Apply ifupdown configuration"))
      (when "(item.item.key | d() and item is changed)"))
    (task "Remove custom configuration files"
      (ansible.builtin.file 
        (path (jinja "{{ item.dest | d(item.path) }}"))
        (state "absent"))
      (loop (jinja "{{ q(\"flattened\", ifupdown__custom_files
                           + ifupdown__custom_group_files
                           + ifupdown__custom_host_files
                           + ifupdown__custom_dependent_files) }}"))
      (when "((item.dest | d() or item.path | d()) and item.state | d('present') == 'absent')"))
    (task "Generate custom configuration files"
      (ansible.builtin.copy 
        (dest (jinja "{{ item.dest | d(item.path) }}"))
        (src (jinja "{{ item.src | d(omit) }}"))
        (content (jinja "{{ item.content | d(omit) }}"))
        (owner (jinja "{{ item.owner | d(\"root\") }}"))
        (group (jinja "{{ item.group | d(\"root\") }}"))
        (mode (jinja "{{ item.mode | d(\"0644\") }}"))
        (force (jinja "{{ item.force | d(omit) }}")))
      (loop (jinja "{{ q(\"flattened\", ifupdown__custom_files
                           + ifupdown__custom_group_files
                           + ifupdown__custom_host_files
                           + ifupdown__custom_dependent_files) }}"))
      (when "((item.dest | d() or item.path | d()) and (item.src | d() or item.content | d()) and item.state | d('present') != 'absent')"))
    (task "Remove custom ifupdown hooks"
      (ansible.builtin.file 
        (path (jinja "{{ item.dest | d(\"/\" + item.hook) }}"))
        (state "absent"))
      (loop (jinja "{{ q(\"flattened\", ifupdown__custom_hooks) }}"))
      (when "item.name | d() and item.state | d('present') == 'absent'"))
    (task "Install custom ifupdown hooks"
      (ansible.builtin.template 
        (src (jinja "{{ item.src | d(item.hook + \".j2\") }}"))
        (dest (jinja "{{ item.dest | d(\"/\" + item.hook) }}"))
        (owner "root")
        (group "root")
        (mode (jinja "{{ item.mode | d(\"0755\") }}")))
      (loop (jinja "{{ q(\"flattened\", ifupdown__custom_hooks) }}"))
      (when "item.name | d() and item.state | d('present') != 'absent'"))
    (task "Install reconfiguration script if needed"
      (ansible.builtin.copy 
        (src "script/ifupdown-reconfigure-interfaces")
        (dest (jinja "{{ ifupdown__reconfigure_script_path }}"))
        (owner "root")
        (group "root")
        (mode "0755"))
      (when "not ifupdown__reconfigure_auto | bool"))
    (task "Save role version information"
      (community.general.ini_file 
        (dest (jinja "{{ ansible_local.debops_fact.public_facts | d(\"/etc/ansible/debops_fact.ini\") }}"))
        (section "version")
        (option "ifupdown")
        (value (jinja "{{ ifupdown__role_metadata.version }}"))
        (mode "0644"))
      (when "ansible_local | d() and ansible_local.debops_fact | d() and ansible_local.debops_fact.enabled | bool"))))
