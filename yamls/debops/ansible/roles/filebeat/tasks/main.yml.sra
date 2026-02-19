(playbook "debops/ansible/roles/filebeat/tasks/main.yml"
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
    (task "Install Filebeat packages"
      (ansible.builtin.package 
        (name (jinja "{{ q(\"flattened\", (filebeat__base_packages
                              + filebeat__packages)) }}"))
        (state "present"))
      (notify (list
          "Refresh host facts"))
      (register "filebeat__register_packages")
      (until "filebeat__register_packages is succeeded"))
    (task "Make sure that Ansible local facts directory exists"
      (ansible.builtin.file 
        (path "/etc/ansible/facts.d")
        (state "directory")
        (mode "0755")))
    (task "Save Filebeat local facts"
      (ansible.builtin.template 
        (src "etc/ansible/facts.d/filebeat.fact.j2")
        (dest "/etc/ansible/facts.d/filebeat.fact")
        (mode "0755"))
      (notify (list
          "Refresh host facts"))
      (tags (list
          "meta::facts")))
    (task "Update Ansible facts if they were modified"
      (ansible.builtin.meta "flush_handlers"))
    (task "Divert the original Filebeat configuration"
      (debops.debops.dpkg_divert 
        (path "/etc/filebeat/filebeat.yml")
        (state "present"))
      (register "filebeat__register_config_divert")
      (when "ansible_pkg_mgr == 'apt'"))
    (task "Generate main Filebeat configuration"
      (ansible.builtin.template 
        (src "etc/filebeat/filebeat.yml.j2")
        (dest "/etc/filebeat/filebeat.yml")
        (mode "0600"))
      (notify (list
          "Test filebeat configuration and restart"))
      (no_log (jinja "{{ debops__no_log | d(True) }}")))
    (task "Create required configuration directories"
      (ansible.builtin.file 
        (path (jinja "{{ \"/etc/filebeat/\" + (item.name | dirname) }}"))
        (state "directory")
        (mode "0755"))
      (loop (jinja "{{ filebeat__combined_snippets | debops.debops.parse_kv_config }}"))
      (loop_control 
        (label (jinja "{{ {\"name\": item.name, \"state\": item.state} }}")))
      (when "item.state | d('present') not in ['absent', 'ignore', 'init'] and item.config | d()")
      (no_log (jinja "{{ debops__no_log | d(True) }}")))
    (task "Remove snippet configuration if requested"
      (ansible.builtin.file 
        (path (jinja "{{ \"/etc/filebeat/\" + (item.name | regex_replace(\".yml\", \"\") + \".yml\") }}"))
        (state "absent"))
      (loop (jinja "{{ filebeat__combined_snippets | debops.debops.parse_kv_config }}"))
      (loop_control 
        (label (jinja "{{ {\"name\": item.name, \"state\": item.state, \"config\": item.config} }}")))
      (notify (list
          "Test filebeat configuration and restart"))
      (when "item.state | d('present') == 'absent' and item.config | d()")
      (no_log (jinja "{{ debops__no_log | d(True) }}")))
    (task "Generate snippet configuration"
      (ansible.builtin.template 
        (src "etc/filebeat/snippets.d/snippet.yml.j2")
        (dest (jinja "{{ \"/etc/filebeat/\" + (item.name | regex_replace(\".yml\", \"\") + \".yml\") }}"))
        (mode (jinja "{{ item.mode | d(\"0600\") }}")))
      (loop (jinja "{{ filebeat__combined_snippets | debops.debops.parse_kv_config }}"))
      (loop_control 
        (label (jinja "{{ {\"name\": item.name, \"state\": item.state, \"config\": item.config} }}")))
      (notify (list
          "Test filebeat configuration and restart"))
      (when "item.state | d('present') not in ['absent', 'ignore', 'init'] and item.config | d()")
      (no_log (jinja "{{ debops__no_log | d(True) }}")))
    (task "Check if the Filebeat keystore exists"
      (ansible.builtin.stat 
        (path "/var/lib/filebeat/filebeat.keystore"))
      (register "filebeat__register_keystore"))
    (task "Create Filebeat keystore if not present"
      (ansible.builtin.command "filebeat keystore create")
      (register "filebeat__register_keystore_create")
      (changed_when "filebeat__register_keystore_create.changed | bool")
      (when "not filebeat__register_keystore.stat.exists"))
    (task "Get the list of keystore contents"
      (ansible.builtin.command "filebeat keystore list")
      (register "filebeat__register_keys")
      (changed_when "False")
      (check_mode "False"))
    (task "Remove key from Filebeat keystore when requested"
      (ansible.builtin.command "filebeat keystore remove " (jinja "{{ item.name }}"))
      (loop (jinja "{{ filebeat__combined_keys | debops.debops.parse_kv_config }}"))
      (loop_control 
        (label (jinja "{{ {\"name\": item.name, \"state\": item.state} }}")))
      (notify (list
          "Test filebeat configuration and restart"))
      (register "filebeat__register_keystore_remove")
      (changed_when "filebeat__register_keystore_remove.changed | bool")
      (when "(item.state | d('present') == 'absent' and item.name in filebeat__register_keys.stdout_lines)")
      (no_log (jinja "{{ debops__no_log | d(True) }}")))
    (task "Set or update key in Filebeat keystore"
      (ansible.builtin.shell "set -o nounset -o pipefail -o errexit &&
" (jinja "{% if item.force | d(False) %}") "
printf \"%s\" \"${DEBOPS_FILEBEAT_KEY}\" | filebeat keystore add \"" (jinja "{{ item.name }}") "\" --stdin --force
" (jinja "{% else %}") "
printf \"%s\" \"${DEBOPS_FILEBEAT_KEY}\" | filebeat keystore add \"" (jinja "{{ item.name }}") "\" --stdin
" (jinja "{% endif %}") "
")
      (environment 
        (DEBOPS_FILEBEAT_KEY (jinja "{{ item.value }}")))
      (args 
        (executable "bash"))
      (loop (jinja "{{ filebeat__combined_keys | debops.debops.parse_kv_config }}"))
      (loop_control 
        (label (jinja "{{ {\"name\": item.name, \"state\": item.state} }}")))
      (notify (list
          "Test filebeat configuration and restart"))
      (register "filebeat__register_keystore_add")
      (changed_when "filebeat__register_keystore_add.changed | bool")
      (when "(item.state | d('present') not in ['absent', 'ignore', 'init'] and (item.name not in filebeat__register_keys.stdout_lines or (item.force | d(False)) | bool))")
      (no_log (jinja "{{ debops__no_log | d(True) }}")))
    (task "Enable filebeat service on installation"
      (ansible.builtin.service 
        (name "filebeat")
        (enabled "True"))
      (when "filebeat__register_config_divert is changed"))))
