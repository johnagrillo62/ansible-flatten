(playbook "debops/ansible/roles/ferm/tasks/main.yml"
  (tasks
    (task "Import custom Ansible plugins"
      (ansible.builtin.import_role 
        (name "ansible_plugins")))
    (task "Import DebOps global handlers"
      (ansible.builtin.import_role 
        (name "global_handlers")))
    (task "Configure ferm status in debconf"
      (ansible.builtin.debconf 
        (name "ferm")
        (question "ferm/enable")
        (vtype "boolean")
        (value (jinja "{{ \"yes\" if ferm__enabled | bool else \"no\" }}")))
      (when "ansible_pkg_mgr == 'apt'"))
    (task "Ensure ferm is installed"
      (ansible.builtin.package 
        (name (jinja "{{ q(\"flattened\", (ferm__base_packages
                              + ferm__packages)) }}"))
        (state "present"))
      (register "ferm__register_packages")
      (until "ferm__register_packages is succeeded")
      (when "ferm__enabled | bool"))
    (task "Manage iptables backend using alternatives"
      (community.general.alternatives 
        (name (jinja "{{ item.name }}"))
        (path (jinja "{{ item.path }}")))
      (loop (list
          
          (name "arptables")
          (path "/usr/sbin/arptables-" (jinja "{{ ferm__iptables_backend_type }}"))
          
          (name "ebtables")
          (path "/usr/sbin/ebtables-" (jinja "{{ ferm__iptables_backend_type }}"))
          
          (name "iptables")
          (path "/usr/sbin/iptables-" (jinja "{{ ferm__iptables_backend_type }}"))
          
          (name "ip6tables")
          (path "/usr/sbin/ip6tables-" (jinja "{{ ferm__iptables_backend_type }}"))))
      (when "ferm__enabled | bool and ferm__iptables_backend_enabled | bool"))
    (task "Make sure required directories exist"
      (ansible.builtin.file 
        (path (jinja "{{ item }}"))
        (state "directory")
        (owner "root")
        (group "adm")
        (mode "02750"))
      (loop (list
          "/etc/ferm/rules.d"
          "/etc/ferm/filter-input.d"
          "/etc/ferm/hooks/pre.d"
          "/etc/ferm/hooks/post.d"
          "/etc/ferm/hooks/flush.d")))
    (task "Copy custom files to remote hosts"
      (ansible.builtin.copy 
        (src (jinja "{{ item.src | d(omit) }}"))
        (content (jinja "{{ item.content | d(omit) }}"))
        (dest (jinja "{{ item.dest }}"))
        (owner (jinja "{{ item.owner | d(omit) }}"))
        (group (jinja "{{ item.group | d(omit) }}"))
        (mode (jinja "{{ item.mode | d(omit) }}"))
        (directory_mode (jinja "{{ item.directory_mode | d(omit) }}"))
        (follow (jinja "{{ item.follow | d(omit) }}"))
        (force (jinja "{{ item.force | d(omit) }}")))
      (loop (jinja "{{ (ferm__custom_files + ferm__group_custom_files
             + ferm__host_custom_files) | flatten }}"))
      (loop_control 
        (label (jinja "{{ item.dest }}")))
      (when "((item.src is defined or item.content is defined) and item.dest is defined)")
      (register "ferm__register_files")
      (tags (list
          "role::ferm:custom_files")))
    (task "Configure ferm default variables"
      (ansible.builtin.template 
        (src "etc/default/ferm.j2")
        (dest "/etc/default/ferm")
        (owner "root")
        (group "root")
        (mode "0644"))
      (notify (list
          "Restart ferm")))
    (task "Add/remove diversion of /etc/ferm/ferm.conf"
      (debops.debops.dpkg_divert 
        (path "/etc/ferm/ferm.conf")
        (state (jinja "{{ \"present\" if ferm__enabled | bool else \"absent\" }}"))
        (delete "True")))
    (task "Configure main ferm config file"
      (ansible.builtin.template 
        (src "etc/ferm/ferm.conf.j2")
        (dest "/etc/ferm/ferm.conf")
        (owner "root")
        (group "adm")
        (mode "0644"))
      (notify (list
          "Restart ferm"))
      (when "ferm__enabled | bool"))
    (task "Remove firewall rules"
      (ansible.builtin.file 
        (dest "/etc/ferm/rules.d/" (jinja "{{ \"%03d\" | format((ferm__combined_weight_map[item.value.weight_class
                                                 | d(item.value.type | d(\"default\"))] | d(\"80\")) | int
                                + (item.value.weight | d(\"0\")) | int) }}") "_rule_" (jinja "{{ item.value.name | d(item.key) }}") ".conf")
        (state "absent"))
      (loop (jinja "{{ ferm__parsed_rules | dict2items }}"))
      (loop_control 
        (label (jinja "{{ item.key }}")))
      (register "ferm__register_rules_removed")
      (when "(item.value.rule_state | d(item.value.state | d('present')) == 'absent')")
      (tags (list
          "role::ferm:rules")))
    (task "Generate firewall rules"
      (ansible.builtin.template 
        (src "etc/ferm/rules.d/" (jinja "{{ item.value.template | d(\"rule\") }}") ".conf.j2")
        (dest "/etc/ferm/rules.d/" (jinja "{{ \"%03d\" | format((ferm__combined_weight_map[item.value.weight_class
                                                 | d(item.value.type | d(\"default\"))] | d(\"80\")) | int
                                + (item.value.weight | d(\"0\")) | int) }}") "_rule_" (jinja "{{ item.value.name | d(item.key) }}") ".conf")
        (owner "root")
        (group "adm")
        (mode "0644"))
      (loop (jinja "{{ ferm__parsed_rules | d({}) | dict2items }}"))
      (loop_control 
        (label (jinja "{{ item.key }}")))
      (register "ferm__register_rules_created")
      (when "(item.value.rule_state | d(item.value.state | d('present')) not in ['absent', 'ignore'])")
      (tags (list
          "role::ferm:rules")))
    (task "Remove unknown firewall rules"
      (ansible.builtin.shell "find /etc/ferm/rules.d -maxdepth 1 -type f -name '*_rule_" (jinja "{{ item.item.value.name | d(item.item.key) }}") ".conf' ! -name '" (jinja "{{ \"%03d\" | format((ferm__combined_weight_map[item.item.value.weight_class
                                      | d(item.item.value.type | d(\"default\"))] | d(\"80\")) | int
                     + (item.item.value.weight | d(\"0\")) | int) }}") "_rule_" (jinja "{{ item.item.value.name
                                                                         | d(item.item.key) }}") ".conf' -exec rm -vf {} +")
      (loop (jinja "{{ ferm__register_rules_removed.results
            + ferm__register_rules_created.results }}"))
      (loop_control 
        (label (jinja "{{ item.item.key }}")))
      (register "ferm__register_unknown_rules")
      (changed_when "ferm__register_unknown_rules.changed | bool")
      (when "(item.item.key | d() and item is changed)")
      (tags (list
          "role::ferm:rules")))
    (task "Remove iptables INPUT rules if requested"
      (ansible.builtin.file 
        (path "/etc/ferm/filter-input.d/" (jinja "{{ ferm__weight_map[item.weight_class | d()]
           | d(item.weight | d(\"50\")) }}") "_" (jinja "{{ item.filename
           | d(item.type + \"_\" + item.name | d((item.dport[0] if item.dport | d() else \"rules\"))) }}") ".conf")
        (state "absent"))
      (loop (jinja "{{ q(\"flattened\", ferm_input_list
                           + ferm_input_group_list
                           + ferm_input_host_list
                           + ferm_input_dependent_list) }}"))
      (when "(ferm__enabled | bool and item.type | d() and (item.delete | d() | bool))")
      (register "ferm__register_input_rules_del")
      (tags (list
          "role::ferm:rules")))
    (task "Configure iptables INPUT rules"
      (ansible.builtin.template 
        (src "etc/ferm/filter-input.d/" (jinja "{{ item.type }}") ".conf.j2")
        (dest "/etc/ferm/filter-input.d/" (jinja "{{ ferm__weight_map[item.weight_class | d()]
           | d(item.weight | d(\"50\")) }}") "_" (jinja "{{ item.filename
           | d(item.type + \"_\" + item.name | d((item.dport[0] if item.dport | d() else \"rules\"))) }}") ".conf")
        (owner "root")
        (group "adm")
        (mode "0644"))
      (loop (jinja "{{ q(\"flattened\", ferm_input_list
                           + ferm_input_group_list
                           + ferm_input_host_list
                           + ferm_input_dependent_list) }}"))
      (when "(ferm__enabled | bool and item.type | d() and not (item.delete | d() | bool))")
      (register "ferm__register_input_rules_add")
      (tags (list
          "role::ferm:rules")))
    (task "Restart ferm"
      (ansible.builtin.service 
        (name "ferm")
        (state "restarted"))
      (when "(ferm__enabled | bool and (ferm__register_files is changed or ferm__register_rules_created is changed or ferm__register_rules_removed is changed or ferm__register_input_rules_del is changed or ferm__register_input_rules_add is changed) and not ansible_check_mode)"))
    (task "Clear iptables rules if ferm is disabled"
      (ansible.builtin.service 
        (name "ferm")
        (state "stopped"))
      (when "(not ferm__enabled | bool and ferm__flush | bool)")
      (tags (list
          "role::ferm:rules")))
    (task "Remove deprecated ifupdown hook"
      (ansible.builtin.file 
        (path "/etc/network/if-pre-up.d/ferm-forward")
        (state "absent")))
    (task "Disable ferm after changes when requested"
      (ansible.builtin.lineinfile 
        (dest "/etc/default/ferm")
        (regexp "^ENABLED=\"")
        (line "ENABLED=\"no\"")
        (mode "0644"))
      (when "not ferm__enabled | bool and not ansible_check_mode"))
    (task "Ensure that Ansible local facts directory exists"
      (ansible.builtin.file 
        (path "/etc/ansible/facts.d")
        (state "directory")
        (owner "root")
        (group "root")
        (mode "0755")))
    (task "Save ferm local facts"
      (ansible.builtin.template 
        (src "etc/ansible/facts.d/ferm.fact.j2")
        (dest "/etc/ansible/facts.d/ferm.fact")
        (owner "root")
        (group "root")
        (mode "0644"))
      (tags (list
          "meta::facts"
          "role::ferm:rules"))
      (notify (list
          "Refresh host facts")))
    (task "Update Ansible facts if they were modified"
      (ansible.builtin.meta "flush_handlers"))))
