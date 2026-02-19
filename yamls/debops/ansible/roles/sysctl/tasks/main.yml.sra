(playbook "debops/ansible/roles/sysctl/tasks/main.yml"
  (tasks
    (task "Import custom Ansible plugins"
      (ansible.builtin.import_role 
        (name "ansible_plugins")))
    (task "Import DebOps global handlers"
      (ansible.builtin.import_role 
        (name "global_handlers")))
    (task "Pre hooks"
      (ansible.builtin.include_tasks (jinja "{{ lookup(\"debops.debops.task_src\", \"sysctl/pre_main.yml\") }}"))
      (when "sysctl__enabled | bool"))
    (task "Make sure that Ansible local facts directory exists"
      (ansible.builtin.file 
        (path "/etc/ansible/facts.d")
        (state "directory")
        (owner "root")
        (group "root")
        (mode "0755")))
    (task "Save sysctl local facts"
      (ansible.builtin.template 
        (src "etc/ansible/facts.d/sysctl.fact.j2")
        (dest "/etc/ansible/facts.d/sysctl.fact")
        (owner "root")
        (group "root")
        (mode "0755"))
      (notify (list
          "Refresh host facts"))
      (tags (list
          "meta::facts")))
    (task "Update Ansible facts if they were modified"
      (ansible.builtin.meta "flush_handlers"))
    (task "Add/remove diversion of custom sysctl configuration files"
      (debops.debops.dpkg_divert 
        (path "/etc/sysctl.d/" (jinja "{{ item.filename | d(item.weight | string + \"-\" + item.name + \".conf\") }}"))
        (state (jinja "{{ item.state | d(\"present\") }}"))
        (delete "True"))
      (loop (jinja "{{ sysctl__combined_parameters | debops.debops.parse_kv_items }}"))
      (loop_control 
        (label (jinja "{{ {\"name\": item.name, \"state\": item.state | d(\"present\")} }}")))
      (when "(sysctl__enabled | bool and item.name | d() and item.state | d('present') in ['present', 'absent'] and item.divert | d(False) | bool)"))
    (task "Remove custom sysctl configuration files"
      (ansible.builtin.file 
        (path "/etc/sysctl.d/" (jinja "{{ item.filename | d(item.weight | string + \"-\" + item.name + \".conf\") }}"))
        (state "absent"))
      (with_items (jinja "{{ sysctl__combined_parameters | debops.debops.parse_kv_items }}"))
      (register "sysctl__register_config_removed")
      (when "sysctl__enabled | bool and item.name | d() and item.state | d('present') == 'absent'"))
    (task "Generate custom sysctl configuration files"
      (ansible.builtin.template 
        (src "etc/sysctl.d/parameters.conf.j2")
        (dest "/etc/sysctl.d/" (jinja "{{ item.filename | d(item.weight | string + \"-\" + item.name + \".conf\") }}"))
        (owner "root")
        (group "root")
        (mode "0644"))
      (loop (jinja "{{ sysctl__combined_parameters | debops.debops.parse_kv_items }}"))
      (loop_control 
        (label (jinja "{{ item.name }}")))
      (register "sysctl__register_config_created")
      (when "sysctl__enabled | bool and item.name | d() and item.options | d() and item.state | d('present') not in ['absent', 'ignore', 'init']"))
    (task "Check sysctl command capabilities"
      (ansible.builtin.shell "set -o nounset -o pipefail -o errexit && sysctl --help | grep -E '^\\s+\\-\\-system\\s+' || true")
      (args 
        (executable "bash"))
      (register "sysctl__register_system")
      (changed_when "sysctl__register_system.changed | bool")
      (when "(sysctl__enabled | bool and (sysctl__register_config_created is changed or sysctl__register_config_removed is changed))")
      (check_mode "False"))
    (task "Apply kernel parameters if they were modified"
      (ansible.builtin.shell "set -o nounset -o pipefail -o errexit &&
" (jinja "{% if (sysctl__register_system.stdout | d()) %}") "
sysctl --system
" (jinja "{% else %}") "
sysctl -e -p $(find /etc/sysctl.d -mindepth 1 -maxdepth 1 -name '*.conf' -print0 | sort -z | xargs -r0)
             /etc/sysctl.conf
" (jinja "{% endif %}") "
")
      (args 
        (executable "bash"))
      (register "sysctl__register_apply")
      (changed_when "sysctl__register_apply.changed | bool")
      (when "(sysctl__enabled | bool and (sysctl__register_config_created is changed or sysctl__register_config_removed is changed))"))
    (task "Post hooks"
      (ansible.builtin.include_tasks (jinja "{{ lookup(\"debops.debops.task_src\", \"sysctl/post_main.yml\") }}"))
      (when "sysctl__enabled | bool"))))
