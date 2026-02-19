(playbook "debops/ansible/roles/saslauthd/tasks/main.yml"
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
    (task "Install required packages"
      (ansible.builtin.package 
        (name (jinja "{{ q(\"flattened\", (saslauthd__base_packages
                              + saslauthd__packages)) }}"))
        (state "present"))
      (register "saslauthd__register_packages")
      (until "saslauthd__register_packages is succeeded"))
    (task "Stop saslauthd instance before removal"
      (ansible.builtin.command "/etc/init.d/saslauthd stop-instance saslauthd-" (jinja "{{ item.name }}"))
      (with_items (jinja "{{ saslauthd__combined_instances | debops.debops.parse_kv_items }}"))
      (register "saslauthd__register_stop_instance")
      (changed_when "saslauthd__register_stop_instance.changed | bool")
      (when "item.name | d() and item.socket_path | d() and item.state | d('present') == 'absent'"))
    (task "Remove saslauthd instance if requested"
      (ansible.builtin.file 
        (path "/etc/default/saslauthd-" (jinja "{{ item.name }}"))
        (state "absent"))
      (with_items (jinja "{{ saslauthd__combined_instances | debops.debops.parse_kv_items }}"))
      (when "item.name | d() and item.socket_path | d() and item.state | d('present') == 'absent'"))
    (task "Generate saslauthd instance configuration"
      (ansible.builtin.template 
        (src "etc/default/saslauthd.j2")
        (dest "/etc/default/saslauthd-" (jinja "{{ item.name }}"))
        (owner "root")
        (group "root")
        (mode "0644"))
      (with_items (jinja "{{ saslauthd__combined_instances | debops.debops.parse_kv_items }}"))
      (notify (list
          "Restart saslauthd"))
      (when "item.name | d() and item.socket_path | d() and item.state | d('present') != 'absent'"))
    (task "Ensure that required UNIX groups exist"
      (ansible.builtin.group 
        (name (jinja "{{ item.group }}"))
        (state "present")
        (system (jinja "{{ (item.system | d(True)) | bool }}")))
      (with_items (jinja "{{ saslauthd__combined_instances | debops.debops.parse_kv_items }}"))
      (when "item.name | d() and item.group | d() and item.state | d('present') != 'absent'"))
    (task "Create SASL config directory"
      (ansible.builtin.file 
        (path (jinja "{{ item.config_path | dirname }}"))
        (state "directory")
        (owner (jinja "{{ item.config_dir_owner | d(\"root\") }}"))
        (group (jinja "{{ item.config_dir_group | d(\"root\") }}"))
        (mode (jinja "{{ item.config_dir_mode | d(\"0755\") }}")))
      (with_items (jinja "{{ saslauthd__combined_instances | debops.debops.parse_kv_items }}"))
      (when "item.name | d() and item.config_path | d() and item.state | d('present') != 'absent'"))
    (task "Remove SASL instance configuration if requested"
      (ansible.builtin.file 
        (path (jinja "{{ item.config_path }}"))
        (state "absent"))
      (with_items (jinja "{{ saslauthd__combined_instances | debops.debops.parse_kv_items }}"))
      (notify (jinja "{{ item.notify if item.notify | d() else omit }}"))
      (when "item.name | d() and item.config_path | d() and item.state | d('present') == 'absent'"))
    (task "Generate SASL instance configuration"
      (ansible.builtin.template 
        (src "etc/instance.conf.j2")
        (dest (jinja "{{ item.config_path }}"))
        (owner (jinja "{{ item.config_owner | d(\"root\") }}"))
        (group (jinja "{{ item.config_group | d(\"sasl\") }}"))
        (mode (jinja "{{ item.config_mode | d(\"0640\") }}")))
      (with_items (jinja "{{ saslauthd__combined_instances | debops.debops.parse_kv_items }}"))
      (notify (jinja "{{ item.notify if item.notify | d() else omit }}"))
      (when "item.name | d() and item.config_path | d() and item.state | d('present') != 'absent'"))
    (task "Remove SASL LDAP profiles if requested"
      (ansible.builtin.file 
        (path (jinja "{{ \"/etc/saslauthd.conf\"
              if (item.name == \"global\")
              else \"/etc/saslauthd-\" + item.name + \".conf\" }}"))
        (state "absent"))
      (with_items (jinja "{{ saslauthd__ldap_combined_profiles | debops.debops.parse_kv_items }}"))
      (when "item.name | d() and item.state | d('present') == 'absent'"))
    (task "Generate SASL LDAP profiles"
      (ansible.builtin.template 
        (src "etc/saslauthd.conf.j2")
        (dest (jinja "{{ \"/etc/saslauthd.conf\"
              if (item.name == \"global\")
              else \"/etc/saslauthd-\" + item.name + \".conf\" }}"))
        (owner (jinja "{{ item.owner | d(\"root\") }}"))
        (group (jinja "{{ item.group | d(\"sasl\") }}"))
        (mode (jinja "{{ item.mode | d(\"0640\") }}")))
      (with_items (jinja "{{ saslauthd__ldap_combined_profiles | debops.debops.parse_kv_items }}"))
      (notify (list
          "Restart saslauthd"))
      (when "item.name | d() and item.state | d('present') not in ['absent', 'ignore']"))
    (task "Get list of dpkg-stateoverride paths"
      (ansible.builtin.shell "set -o nounset -o pipefail -o errexit && dpkg-statoverride --list | awk '{print $4}'")
      (args 
        (executable "bash"))
      (register "saslauthd__register_statoverride")
      (changed_when "False")
      (check_mode "False"))
    (task "Remove a dpkg-statoverride entry if requested"
      (ansible.builtin.command "dpkg-statoverride --remove " (jinja "{{ item.socket_path }}"))
      (with_items (jinja "{{ saslauthd__combined_instances | debops.debops.parse_kv_items }}"))
      (notify (list
          "Restart saslauthd"))
      (register "saslauthd__register_statoverride_remove")
      (changed_when "saslauthd__register_statoverride_remove.changed | bool")
      (when "item.name | d() and item.socket_path | d() and item.state | d('present') == 'absent' and item.socket_path in saslauthd__register_statoverride.stdout_lines"))
    (task "Create a dpkg-statoverride entry"
      (ansible.builtin.command "dpkg-statoverride --add " (jinja "{{ item.socket_owner | d('root') }}") " " (jinja "{{ item.socket_group | d('sasl') }}") " " (jinja "{{ item.socket_mode | d('710') }}") " " (jinja "{{ item.socket_path }}"))
      (with_items (jinja "{{ saslauthd__combined_instances | debops.debops.parse_kv_items }}"))
      (notify (list
          "Restart saslauthd"))
      (register "saslauthd__register_statoverride_add")
      (changed_when "saslauthd__register_statoverride_add.changed | bool")
      (when "item.name | d() and item.socket_path | d() and item.state | d('present') != 'absent' and item.socket_path not in saslauthd__register_statoverride.stdout_lines"))
    (task "Make sure that Ansible local facts directory exists"
      (ansible.builtin.file 
        (path "/etc/ansible/facts.d")
        (state "directory")
        (owner "root")
        (group "root")
        (mode "0755")))
    (task "Save saslauthd local facts"
      (ansible.builtin.template 
        (src "etc/ansible/facts.d/saslauthd.fact.j2")
        (dest "/etc/ansible/facts.d/saslauthd.fact")
        (owner "root")
        (group "root")
        (mode "0755"))
      (notify (list
          "Refresh host facts"))
      (tags (list
          "meta::facts")))
    (task "Update Ansible facts if they were modified"
      (ansible.builtin.meta "flush_handlers"))))
