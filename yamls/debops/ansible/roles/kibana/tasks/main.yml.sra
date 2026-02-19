(playbook "debops/ansible/roles/kibana/tasks/main.yml"
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
    (task "Install Kibana packages"
      (ansible.builtin.package 
        (name (jinja "{{ q(\"flattened\", (kibana__base_packages
                              + kibana__packages)) }}"))
        (state "present"))
      (notify (list
          "Refresh host facts"))
      (register "kibana__register_packages")
      (until "kibana__register_packages is succeeded"))
    (task "Add Kibana UNIX account to selected groups"
      (ansible.builtin.user 
        (name (jinja "{{ kibana__user }}"))
        (groups (jinja "{{ kibana__additional_groups }}"))
        (append "True"))
      (when "kibana__additional_groups | d()"))
    (task "Make sure that Ansible local facts directory exists"
      (ansible.builtin.file 
        (path "/etc/ansible/facts.d")
        (state "directory")
        (owner "root")
        (group "root")
        (mode "0755")))
    (task "Save Kibana local facts"
      (ansible.builtin.template 
        (src "etc/ansible/facts.d/kibana.fact.j2")
        (dest "/etc/ansible/facts.d/kibana.fact")
        (owner "root")
        (group "root")
        (mode "0755"))
      (notify (list
          "Refresh host facts"))
      (tags (list
          "meta::facts")))
    (task "Update Ansible facts if they were modified"
      (ansible.builtin.meta "flush_handlers"))
    (task "Check if the dependent config file exists"
      (ansible.builtin.stat 
        (path (jinja "{{ secret + \"/kibana/dependent_config/\" + inventory_hostname + \"/config.json\" }}")))
      (register "kibana__register_dependent_config_file")
      (become "False")
      (delegate_to "localhost")
      (when "(ansible_local.kibana.installed | d())")
      (tags (list
          "role::kibana:config")))
    (task "Load the dependent configuration from Ansible Controller"
      (ansible.builtin.slurp 
        (src (jinja "{{ secret + \"/kibana/dependent_config/\" + inventory_hostname + \"/config.json\" }}")))
      (register "kibana__register_dependent_config")
      (become "False")
      (delegate_to "localhost")
      (when "(ansible_local.kibana.installed | d() and kibana__register_dependent_config_file.stat.exists | bool)")
      (tags (list
          "role::kibana:config")))
    (task "Divert original configuration files"
      (debops.debops.dpkg_divert 
        (path "/etc/kibana/kibana.yml"))
      (notify (list
          "Start kibana"))
      (tags (list
          "role::kibana:config")))
    (task "Generate Kibana configuration"
      (ansible.builtin.template 
        (src "etc/kibana/kibana.yml.j2")
        (dest "/etc/kibana/kibana.yml")
        (owner "root")
        (group (jinja "{{ kibana__group }}"))
        (mode "0660"))
      (notify (list
          "Restart kibana"))
      (tags (list
          "role::kibana:config")))
    (task "Check state of installed Kibana plugins"
      (ansible.builtin.shell "set -o nounset -o pipefail -o errexit && bin/kibana-plugin list | cut -d@ -f1")
      (args 
        (executable "bash")
        (chdir "/usr/share/kibana"))
      (register "kibana__register_plugins")
      (become "True")
      (become_user (jinja "{{ kibana__user }}"))
      (changed_when "False")
      (check_mode "False"))
    (task "Install Kibana plugins"
      (ansible.builtin.command "bin/kibana-plugin install " (jinja "{{ item.url | d(item.name) }}"))
      (args 
        (chdir "/usr/share/kibana"))
      (notify (list
          "Restart kibana"))
      (become "True")
      (become_user (jinja "{{ item.user | d(kibana__user) }}"))
      (loop (jinja "{{ q(\"flattened\", kibana__combined_plugins) }}"))
      (register "kibana__register_plugin_install")
      (changed_when "kibana__register_plugin_install.changed | bool")
      (when "(item.name | d() and item.state | d('present') != 'absent' and (item.name if ':' not in item.name else item.name.split(':')[1]) not in kibana__register_plugins.stdout_lines)"))
    (task "Remove Kibana plugins"
      (ansible.builtin.command "bin/kibana-plugin remove " (jinja "{{ item.name }}"))
      (args 
        (chdir "/usr/share/kibana"))
      (notify (list
          "Restart kibana"))
      (become "True")
      (become_user (jinja "{{ item.user | d(kibana__user) }}"))
      (loop (jinja "{{ q(\"flattened\", kibana__combined_plugins) }}"))
      (register "kibana__register_plugin_remove")
      (changed_when "kibana__register_plugin_remove.changed | bool")
      (when "(item.name | d() and item.state | d('present') == 'absent' and (item.name if ':' not in item.name else item.name.split(':')[1]) in kibana__register_plugins.stdout_lines)"))
    (task "Check if the Kibana keystore exists"
      (ansible.builtin.stat 
        (path (jinja "{{ kibana__keystore_path }}")))
      (register "kibana__register_keystore"))
    (task "Create Kibana keystore if not present"
      (ansible.builtin.command "bin/kibana-keystore create")
      (args 
        (chdir "/usr/share/kibana"))
      (register "kibana__register_keystore_create")
      (changed_when "kibana__register_keystore_create.changed | bool")
      (when "not kibana__register_keystore.stat.exists"))
    (task "Get the list of keystore contents"
      (ansible.builtin.command "bin/kibana-keystore list")
      (args 
        (chdir "/usr/share/kibana"))
      (register "kibana__register_keys")
      (changed_when "False")
      (check_mode (jinja "{{ False if ansible_local.kibana.installed | d() else omit }}")))
    (task "Remove key from Kibana keystore when requested"
      (ansible.builtin.command "bin/kibana-keystore remove " (jinja "{{ item.name }}"))
      (args 
        (chdir "/usr/share/kibana"))
      (loop (jinja "{{ kibana__combined_keys | debops.debops.parse_kv_config }}"))
      (loop_control 
        (label (jinja "{{ {\"name\": item.name, \"state\": item.state} }}")))
      (notify (list
          "Restart kibana"))
      (register "kibana__register_keystore_remove")
      (changed_when "kibana__register_keystore_remove.changed | bool")
      (when "(item.state | d('present') == 'absent' and item.name in kibana__register_keys.stdout_lines)")
      (no_log (jinja "{{ debops__no_log | d(True) }}")))
    (task "Set or update key in Kibana keystore"
      (ansible.builtin.shell "set -o nounset -o pipefail -o errexit &&
" (jinja "{% if item.force | d(False) %}") "
printf \"%s\" \"${DEBOPS_KIBANA_KEY}\" | bin/kibana-keystore add \"" (jinja "{{ item.name }}") "\" --stdin --force
" (jinja "{% else %}") "
printf \"%s\" \"${DEBOPS_KIBANA_KEY}\" | bin/kibana-keystore add \"" (jinja "{{ item.name }}") "\" --stdin
" (jinja "{% endif %}") "
")
      (environment 
        (DEBOPS_KIBANA_KEY (jinja "{{ item.value }}")))
      (args 
        (chdir "/usr/share/kibana")
        (executable "bash"))
      (loop (jinja "{{ kibana__combined_keys | debops.debops.parse_kv_config }}"))
      (loop_control 
        (label (jinja "{{ {\"name\": item.name, \"state\": item.state} }}")))
      (notify (list
          "Restart kibana"))
      (register "kibana__register_keystore_add")
      (changed_when "kibana__register_keystore_add.changed | bool")
      (when "(item.state | d('present') not in ['absent', 'ignore', 'init'] and (item.name not in kibana__register_keys.stdout_lines or (item.force | d(False)) | bool))")
      (no_log (jinja "{{ debops__no_log | d(True) }}")))
    (task "Save Kibana dependent configuration on Ansible Controller"
      (ansible.builtin.template 
        (src "secret/kibana/dependent_config/config.json.j2")
        (dest (jinja "{{ secret + \"/kibana/dependent_config/\" + inventory_hostname + \"/config.json\" }}"))
        (mode "0644"))
      (become "False")
      (delegate_to "localhost")
      (tags (list
          "role::kibana:config")))))
