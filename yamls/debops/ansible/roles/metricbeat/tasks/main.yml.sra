(playbook "debops/ansible/roles/metricbeat/tasks/main.yml"
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
    (task "Install Metricbeat packages"
      (ansible.builtin.package 
        (name (jinja "{{ q(\"flattened\", (metricbeat__base_packages
                              + metricbeat__packages)) }}"))
        (state "present"))
      (notify (list
          "Refresh host facts"))
      (register "metricbeat__register_packages")
      (until "metricbeat__register_packages is succeeded"))
    (task "Make sure that Ansible local facts directory exists"
      (ansible.builtin.file 
        (path "/etc/ansible/facts.d")
        (state "directory")
        (mode "0755")))
    (task "Save Metricbeat local facts"
      (ansible.builtin.template 
        (src "etc/ansible/facts.d/metricbeat.fact.j2")
        (dest "/etc/ansible/facts.d/metricbeat.fact")
        (mode "0755"))
      (notify (list
          "Refresh host facts"))
      (tags (list
          "meta::facts")))
    (task "Update Ansible facts if they were modified"
      (ansible.builtin.meta "flush_handlers"))
    (task "Divert the original Metricbeat configuration"
      (debops.debops.dpkg_divert 
        (path "/etc/metricbeat/metricbeat.yml")
        (state "present"))
      (register "metricbeat__register_config_divert")
      (when "ansible_pkg_mgr == 'apt'"))
    (task "Generate main Metricbeat configuration"
      (ansible.builtin.template 
        (src "etc/metricbeat/metricbeat.yml.j2")
        (dest "/etc/metricbeat/metricbeat.yml")
        (mode "0600"))
      (notify (list
          "Test metricbeat configuration and restart"))
      (no_log (jinja "{{ debops__no_log | d(True) }}")))
    (task "Create required configuration directories"
      (ansible.builtin.file 
        (path (jinja "{{ \"/etc/metricbeat/\" + (item.name | dirname) }}"))
        (state "directory")
        (mode "0755"))
      (loop (jinja "{{ metricbeat__combined_snippets | debops.debops.parse_kv_config }}"))
      (loop_control 
        (label (jinja "{{ {\"name\": item.name, \"state\": item.state} }}")))
      (when "item.state | d('present') not in ['absent', 'ignore', 'init'] and item.config | d()")
      (no_log (jinja "{{ debops__no_log | d(True) }}")))
    (task "Manage snippet diversion and reversion"
      (debops.debops.dpkg_divert 
        (path (jinja "{{ \"/etc/metricbeat/\" + (item.name | regex_replace(\".yml\", \"\") + \".yml\") }}"))
        (state (jinja "{{ \"absent\" if item.state | d(\"present\") == \"absent\" else \"present\" }}"))
        (delete "True"))
      (loop (jinja "{{ metricbeat__combined_snippets | debops.debops.parse_kv_config }}"))
      (loop_control 
        (label (jinja "{{ {\"name\": item.name, \"state\": item.state} }}")))
      (notify (list
          "Test metricbeat configuration and restart"))
      (when "ansible_pkg_mgr == 'apt' and item.config | d() and (item.divert | d())")
      (no_log (jinja "{{ debops__no_log | d(True) }}")))
    (task "Remove snippet configuration if requested"
      (ansible.builtin.file 
        (path (jinja "{{ \"/etc/metricbeat/\" + (item.name | regex_replace(\".yml\", \"\") + \".yml\") }}"))
        (state "absent"))
      (loop (jinja "{{ metricbeat__combined_snippets | debops.debops.parse_kv_config }}"))
      (loop_control 
        (label (jinja "{{ {\"name\": item.name, \"state\": item.state, \"config\": item.config} }}")))
      (notify (list
          "Test metricbeat configuration and restart"))
      (when "item.state | d('present') == 'absent' and item.config | d()")
      (no_log (jinja "{{ debops__no_log | d(True) }}")))
    (task "Generate snippet configuration"
      (ansible.builtin.template 
        (src "etc/metricbeat/snippets.d/snippet.yml.j2")
        (dest (jinja "{{ \"/etc/metricbeat/\" + (item.name | regex_replace(\".yml\", \"\") + \".yml\") }}"))
        (mode (jinja "{{ item.mode | d(\"0600\") }}")))
      (loop (jinja "{{ metricbeat__combined_snippets | debops.debops.parse_kv_config }}"))
      (loop_control 
        (label (jinja "{{ {\"name\": item.name, \"state\": item.state, \"config\": item.config} }}")))
      (notify (list
          "Test metricbeat configuration and restart"))
      (when "item.state | d('present') not in ['absent', 'ignore', 'init'] and item.config | d()")
      (no_log (jinja "{{ debops__no_log | d(True) }}")))
    (task "Check if the Metricbeat keystore exists"
      (ansible.builtin.stat 
        (path "/var/lib/metricbeat/metricbeat.keystore"))
      (register "metricbeat__register_keystore"))
    (task "Create Metricbeat keystore if not present"
      (ansible.builtin.command "metricbeat keystore create")
      (register "metricbeat__register_keystore_create")
      (changed_when "metricbeat__register_keystore_create.changed | bool")
      (when "not metricbeat__register_keystore.stat.exists"))
    (task "Get the list of keystore contents"
      (ansible.builtin.command "metricbeat keystore list")
      (register "metricbeat__register_keys")
      (changed_when "False")
      (check_mode (jinja "{{ False if ansible_local.metricbeat.installed | d() else omit }}")))
    (task "Remove key from Metricbeat keystore when requested"
      (ansible.builtin.command "metricbeat keystore remove " (jinja "{{ item.name }}"))
      (loop (jinja "{{ metricbeat__combined_keys | debops.debops.parse_kv_config }}"))
      (loop_control 
        (label (jinja "{{ {\"name\": item.name, \"state\": item.state} }}")))
      (notify (list
          "Test metricbeat configuration and restart"))
      (register "metricbeat__register_keystore_remove")
      (changed_when "metricbeat__register_keystore_remove.changed | bool")
      (when "(item.state | d('present') == 'absent' and item.name in metricbeat__register_keys.stdout_lines)")
      (no_log (jinja "{{ debops__no_log | d(True) }}")))
    (task "Set or update key in Metricbeat keystore"
      (ansible.builtin.shell "set -o nounset -o pipefail -o errexit &&
" (jinja "{% if item.force | d(False) %}") "
printf \"%s\" \"${DEBOPS_METRICBEAT_KEY}\" | metricbeat keystore add \"" (jinja "{{ item.name }}") "\" --stdin --force
" (jinja "{% else %}") "
printf \"%s\" \"${DEBOPS_METRICBEAT_KEY}\" | metricbeat keystore add \"" (jinja "{{ item.name }}") "\" --stdin
" (jinja "{% endif %}") "
")
      (environment 
        (DEBOPS_METRICBEAT_KEY (jinja "{{ item.value }}")))
      (args 
        (executable "bash"))
      (loop (jinja "{{ metricbeat__combined_keys | debops.debops.parse_kv_config }}"))
      (loop_control 
        (label (jinja "{{ {\"name\": item.name, \"state\": item.state} }}")))
      (notify (list
          "Test metricbeat configuration and restart"))
      (register "metricbeat__register_keystore_add")
      (changed_when "metricbeat__register_keystore_add.changed | bool")
      (when "(item.state | d('present') not in ['absent', 'ignore', 'init'] and (item.name not in metricbeat__register_keys.stdout_lines or (item.force | d(False)) | bool))")
      (no_log (jinja "{{ debops__no_log | d(True) }}")))
    (task "Enable metricbeat service on installation"
      (ansible.builtin.service 
        (name "metricbeat")
        (enabled "True"))
      (when "ansible_local.metricbeat.installed | d() and metricbeat__register_config_divert is changed"))))
