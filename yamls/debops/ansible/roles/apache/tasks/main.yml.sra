(playbook "debops/ansible/roles/apache/tasks/main.yml"
  (tasks
    (task "Import custom Ansible plugins"
      (ansible.builtin.import_role 
        (name "ansible_plugins")))
    (task "Ensure optional packages are in there desired state"
      (ansible.builtin.package 
        (name (jinja "{{ q(\"flattened\", (apache__packages
                              + apache__group_packages
                              + apache__host_packages
                              + apache__dependent_packages)) }}"))
        (state (jinja "{{ \"present\" if (apache__deploy_state == \"present\") else \"absent\" }}")))
      (register "apache__register_packages")
      (until "apache__register_packages is succeeded"))
    (task "Get list of available modules"
      (ansible.builtin.find 
        (file_type "file")
        (paths (list
            (jinja "{{ apache__config_path + \"/mods-available/\" }}")))
        (patterns (list
            "*.load")))
      (register "apache__register_mods_available")
      (tags (list
          "role::apache:modules")))
    (task "Set list of available modules"
      (ansible.builtin.set_fact 
        (apache__tpl_available_modules (jinja "{{ apache__register_mods_available.files | d({})
                                       | map(attribute=\"path\")
                                       | map(\"replace\", apache__config_path + \"/mods-available/\", \"\")
                                       | map(\"regex_replace\", \"\\.load$\", \"\") | list }}")))
      (tags (list
          "role::apache:modules")))
    (task "Configure Apache module state"
      (ansible.builtin.include_tasks "apache_module_state.yml"))
    (task "Divert conf-available configuration"
      (debops.debops.dpkg_divert 
        (path (jinja "{{ apache__config_path + \"/conf-available/\" + item.key + \".conf\" }}"))
        (divert (jinja "{{ (item.value.divert
                 | d(apache__config_path + \"/conf-available/\"
                     + (item.value.divert_filename | d(item.key)) + \".conf\"))
                + item.value.divert_suffix | d(\".dpkg-divert\") }}")))
      (when "(item.value.type | d(\"default\") in [\"divert\"])")
      (with_dict (jinja "{{ apache__combined_snippets }}")))
    (task "Remove conf-available snippets"
      (ansible.builtin.file 
        (path (jinja "{{ apache__config_path + \"/conf-available/\" + item.key + \".conf\" }}"))
        (state "absent"))
      (when "(item.value.state | d(\"present\") == \"absent\")")
      (with_dict (jinja "{{ apache__combined_snippets }}"))
      (tags (list
          "role::apache:vhosts")))
    (task "Create conf-available snippets"
      (ansible.builtin.template 
        (src "etc/apache2/conf-available/" (jinja "{{ \"raw\"
                                        if (item.value.type | d(\"default\") in [\"divert\", \"raw\"] and
                                            item.value.raw | d())
                                        else item.key }}") ".conf.j2")
        (dest (jinja "{{ apache__config_path + \"/conf-available/\" + item.key + \".conf\" }}"))
        (owner "root")
        (group "root")
        (mode "0644"))
      (when "(item.value.state | d(\"present\") != \"absent\" and (item.value.type | d(\"default\") not in [\"divert\", \"dont-create\"] or item.value.raw | d()))")
      (with_dict (jinja "{{ apache__combined_snippets }}"))
      (notify (list
          "Test apache and reload")))
    (task "Enable/disable configuration snippets"
      (ansible.builtin.file 
        (path (jinja "{{ apache__config_path + \"/conf-enabled/\" + item.key + \".conf\" }}"))
        (src (jinja "{{ (((item.value.enabled | d(True)
                  if (item.value is mapping)
                  else item.value | d(True)))
                 if (item.value.state | d(\"present\") != \"absent\")
                 else False) | bool
                 | ternary(\"../conf-available/\" + item.key + \".conf\",
                           omit) }}"))
        (mode "0644")
        (force (jinja "{{ ansible_check_mode | d() | bool }}"))
        (state (jinja "{{ (((item.value.enabled | d(True)
                  if (item.value is mapping)
                  else item.value | d(True)))
                 if (item.value.state | d(\"present\") != \"absent\")
                 else False) | bool | ternary(\"link\", \"absent\") }}")))
      (when "(item.value.type | d(\"default\") not in [\"divert\"])")
      (with_dict (jinja "{{ apache__combined_snippets }}"))
      (notify (list
          "Test apache and reload")))
    (task "Divert sites-available configuration"
      (debops.debops.dpkg_divert 
        (path (jinja "{{ apache__config_path + \"/sites-available/\"
              + item.filename | d([item.name] | flatten | first | d(\"default\"))
              + \".conf\" }}"))
        (divert (jinja "{{ (item.divert
                 | d(apache__config_path + \"/sites-available/\"
                     + item.divert_filename | d(item.filename | d([item.name] | flatten | first | d(\"default\")))
                     + \".conf\")
                 + item.divert_suffix | d(\".dpkg-divert\")) }}")))
      (when "(item.type | d(apache__vhost_type) in [\"divert\"])")
      (loop (jinja "{{ q(\"flattened\", apache__combined_vhosts) }}")))
    (task "Remove sites-available configuration"
      (ansible.builtin.file 
        (path (jinja "{{ apache__config_path }}") "/sites-available/" (jinja "{{ item.filename | d(item.name
                                                                          if (item.name is string)
                                                                          else item.name[0] | d(\"default\")) }}") ".conf")
        (state "absent"))
      (when "(item.state | d(\"present\") == 'absent')")
      (loop (jinja "{{ q(\"flattened\", apache__combined_vhosts) }}"))
      (tags (list
          "role::apache:vhosts")))
    (task "Create sites-available configuration"
      (ansible.builtin.template 
        (src "etc/apache2/sites-available/" (jinja "{{ item.type | d(apache__vhost_type) }}") ".conf.j2")
        (dest (jinja "{{ apache__config_path }}") "/sites-available/" (jinja "{{ item.filename | d(item.name
                                                                          if (item.name is string)
                                                                          else item.name[0] | d(\"default\")) }}") ".conf")
        (owner "root")
        (group "root")
        (mode "0644"))
      (notify (list
          "Test apache and reload"))
      (when "(item.state | d(\"present\") != \"absent\" and item.type | d(apache__vhost_type) not in [\"divert\", \"dont-create\"])")
      (loop (jinja "{{ q(\"flattened\", apache__combined_vhosts) }}"))
      (tags (list
          "role::apache:vhosts")))
    (task "Enable/disable Apache virtual hosts"
      (ansible.builtin.file 
        (path (jinja "{{ apache__config_path }}") "/sites-enabled/" (jinja "{{ item.filename | d(item.name
                                                                        if (item.name is string)
                                                                        else item.name[0] | d(\"default\")) }}") ".conf")
        (src (jinja "{{ (\"../sites-available/\" + item.filename
                                      | d(item.name
                                          if (item.name is string)
                                          else item.name[0] | d(\"default\")) + \".conf\")
             if (item.enabled | d(True) | bool and (item.state | d(\"present\") != \"absent\"))
             else omit }}"))
        (force (jinja "{{ item.force | d(ansible_check_mode) | bool }}"))
        (state (jinja "{{ item.enabled | d(True) | bool | ternary(\"link\", \"absent\")
               if (item.state | d(\"present\") != \"absent\")
               else \"absent\" }}"))
        (owner "root")
        (group "root")
        (mode "0644"))
      (notify (list
          "Test apache and reload"))
      (when "(item.type | d(apache__vhost_type) not in [\"divert\"])")
      (loop (jinja "{{ q(\"flattened\", apache__combined_vhosts) }}"))
      (tags (list
          "role::apache:vhosts")))
    (task "Detect if the rewrite module has been used in the active configuration"
      (ansible.builtin.shell "grep --recursive --ignore-case '^\\s*RewriteEngine On' " (jinja "{{ apache__config_path | quote }}"))
      (register "apache__register_mod_rewrite_used")
      (check_mode "False")
      (failed_when "apache__register_mod_rewrite_used.rc not in [0, 1]")
      (changed_when "False")
      (when "apache__register_mod_rewrite_used is undefined"))
    (task "Finish configuration of Apache module state"
      (ansible.builtin.include_tasks "apache_module_state.yml"))))
