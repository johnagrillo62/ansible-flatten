(playbook "debops/ansible/roles/icinga/tasks/main.yml"
  (tasks
    (task "Import Custom Ansible plugins"
      (ansible.builtin.import_role 
        (name "ansible_plugins")))
    (task "Import DebOps global handlers"
      (ansible.builtin.import_role 
        (name "global_handlers")))
    (task "Import DebOps secret role"
      (ansible.builtin.import_role 
        (name "secret")))
    (task "Install required Icinga packages"
      (ansible.builtin.package 
        (name (jinja "{{ lookup(\"flattened\",
                     (icinga__base_packages + icinga__packages),
                     wantlist=True) }}"))
        (state "present"))
      (register "icinga__register_packages")
      (until "icinga__register_packages is succeeded"))
    (task "Add Icinga user to system UNIX groups"
      (ansible.builtin.user 
        (name (jinja "{{ icinga__user }}"))
        (groups (jinja "{{ lookup(\"flattened\", icinga__additional_groups, wantlist=True) | join(\",\") }}"))
        (append "True"))
      (notify (list
          "Check icinga2 configuration and restart")))
    (task "Load dependent configuration variables"
      (ansible.builtin.include_vars 
        (dir (jinja "{{ secret + \"/icinga/dependent_config/\" + inventory_hostname }}"))
        (depth "1")
        (name "icinga__vars_dependent_configuration"))
      (when "(ansible_local | d() and ansible_local.icinga | d() and (ansible_local.icinga.configured | d()) | bool)"))
    (task "Make sure that Ansible local facts directory exists"
      (ansible.builtin.file 
        (path "/etc/ansible/facts.d")
        (state "directory")
        (owner "root")
        (group "root")
        (mode "0755")))
    (task "Save Icinga local facts"
      (ansible.builtin.template 
        (src "etc/ansible/facts.d/icinga.fact.j2")
        (dest "/etc/ansible/facts.d/icinga.fact")
        (owner "root")
        (group "root")
        (mode "0755"))
      (notify (list
          "Refresh host facts"))
      (tags (list
          "meta::facts")))
    (task "Update Ansible facts if they were modified"
      (ansible.builtin.meta "flush_handlers"))
    (task "Add/remove diversion of Icinga configuration files"
      (debops.debops.dpkg_divert 
        (path (jinja "{{ \"/etc/icinga2/\" + item.filename | d(item.name | regex_replace(\".conf$\", \"\") + \".conf\") }}"))
        (state (jinja "{{ item.state | d(\"present\") }}"))
        (delete "True"))
      (loop (jinja "{{ icinga__combined_configuration | debops.debops.parse_kv_items }}"))
      (loop_control 
        (label (jinja "{{ {\"name\": item.name, \"state\": item.state | d(\"present\")} }}")))
      (notify (list
          "Check icinga2 configuration and restart"))
      (when "(item.name | d() and item.state | d('present') in ['absent', 'present'] and item.divert | d(False) | bool)"))
    (task "Ensure that configuration directories exist"
      (ansible.builtin.file 
        (path "/etc/icinga2/" (jinja "{{ (item.filename | d(item.name | regex_replace(\".conf$\", \"\") + \".conf\")) | dirname }}"))
        (state "directory")
        (owner "root")
        (group "root")
        (mode "0755"))
      (with_items (jinja "{{ icinga__combined_configuration | debops.debops.parse_kv_items }}"))
      (when "(item.name | d() and item.state | d('present') not in ['absent', 'ignore', 'init', 'feature'] and ((item.filename | d(item.name | regex_replace(\".conf$\", \"\") + \".conf\")) | dirname | d()))"))
    (task "Remove Icinga configuration files"
      (ansible.builtin.file 
        (path "/etc/icinga2/" (jinja "{{ item.filename | d(item.name | regex_replace(\".conf$\", \"\") + \".conf\") }}"))
        (state "absent"))
      (with_items (jinja "{{ icinga__combined_configuration | debops.debops.parse_kv_items }}"))
      (notify (list
          "Check icinga2 configuration and restart"))
      (when "(item.name | d() and item.state | d('present') == 'absent' and not item.divert | d(False) | bool)"))
    (task "Generate Icinga configuration files"
      (ansible.builtin.template 
        (src "etc/icinga2/template.conf.j2")
        (dest "/etc/icinga2/" (jinja "{{ item.filename | d(item.name | regex_replace(\".conf$\", \"\") + \".conf\") }}"))
        (owner (jinja "{{ item.owner | d(\"root\") }}"))
        (group (jinja "{{ item.group | d(\"root\") }}"))
        (mode (jinja "{{ item.mode | d(\"0644\") }}")))
      (with_items (jinja "{{ icinga__combined_configuration | debops.debops.parse_kv_items }}"))
      (notify (list
          "Check icinga2 configuration and restart"))
      (when "(item.name | d() and item.state | d('present') not in ['absent', 'ignore', 'init', 'divert', 'feature'])")
      (no_log (jinja "{{ debops__no_log | d(item.no_log) | d(False) }}")))
    (task "Ensure that configuration directories exist on the master node"
      (ansible.builtin.file 
        (path "/etc/icinga2/zones.d/" (jinja "{{ (item.filename | d(item.name | regex_replace(\".conf$\", \"\") + \".conf\")) | dirname }}"))
        (state "directory")
        (recurse "true")
        (owner "root")
        (group "root")
        (mode "0755"))
      (with_items (jinja "{{ icinga__master_combined_configuration | debops.debops.parse_kv_items }}"))
      (delegate_to (jinja "{{ icinga__master_delegate_to }}"))
      (when "(item.name | d() and item.state | d('present') not in ['absent', 'ignore', 'init', 'feature'] and ((item.filename | d(item.name | regex_replace(\".conf$\", \"\") + \".conf\")) | dirname | d()))"))
    (task "Remove Icinga configuration on the master node if requested"
      (ansible.builtin.file 
        (path "/etc/icinga2/zones.d/" (jinja "{{ item.filename | d(item.name | regex_replace(\".conf$\", \"\") + \".conf\") }}"))
        (state "absent"))
      (with_items (jinja "{{ icinga__master_combined_configuration | debops.debops.parse_kv_items }}"))
      (delegate_to (jinja "{{ icinga__master_delegate_to }}"))
      (notify (list
          "Check icinga2 configuration and restart it on the master node"))
      (when "(item.name | d() and item.state | d('present') == 'absent')"))
    (task "Generate Icinga configuration files on the master node"
      (ansible.builtin.template 
        (src "etc/icinga2/template.conf.j2")
        (dest "/etc/icinga2/zones.d/" (jinja "{{ item.filename | d(item.name | regex_replace(\".conf$\", \"\") + \".conf\") }}"))
        (owner (jinja "{{ item.owner | d(\"root\") }}"))
        (group (jinja "{{ item.group | d(\"root\") }}"))
        (mode (jinja "{{ item.mode | d(\"0644\") }}")))
      (with_items (jinja "{{ icinga__master_combined_configuration | debops.debops.parse_kv_items }}"))
      (delegate_to (jinja "{{ icinga__master_delegate_to }}"))
      (notify (list
          "Check icinga2 configuration and restart it on the master node"))
      (when "(item.name | d() and item.state | d('present') not in ['absent', 'ignore', 'init', 'divert', 'feature'])")
      (no_log (jinja "{{ debops__no_log | d(item.no_log) | d(False) }}")))
    (task "Configure state of Icinga features"
      (ansible.builtin.file 
        (path "/etc/icinga2/features-enabled/" (jinja "{{ item.feature_name }}") ".conf")
        (src (jinja "{{ (\"../features-available/\" + item.feature_name + \".conf\")
             if (item.feature_state | d(\"present\") == \"present\") else omit }}"))
        (state (jinja "{{ \"link\" if item.feature_state | d(\"present\") == \"present\" else \"absent\" }}"))
        (mode "0644")
        (force (jinja "{{ True if ansible_check_mode | bool else omit }}")))
      (with_items (jinja "{{ icinga__combined_configuration | debops.debops.parse_kv_items }}"))
      (notify (list
          "Check icinga2 configuration and restart"))
      (when "(item.name | d() and item.state | d('present') not in ['absent', 'ignore', 'init', 'divert'] and item.feature_name | d() and item.feature_state | d())"))
    (task "Copy custom files for Icinga"
      (ansible.builtin.copy 
        (content (jinja "{{ item.content | d(omit) }}"))
        (src (jinja "{{ item.src | d(omit) }}"))
        (dest (jinja "{{ item.dest | d(omit) }}"))
        (force (jinja "{{ item.force | d(omit) }}"))
        (owner (jinja "{{ item.owner | d(\"root\") }}"))
        (group (jinja "{{ item.group | d(\"root\") }}"))
        (mode (jinja "{{ item.mode | d(\"0755\") }}")))
      (loop (jinja "{{ q(\"flattened\", icinga__custom_files
                           + icinga__group_custom_files
                           + icinga__host_custom_files) }}"))
      (when "((item.src | d() or item.content | d()) and item.dest | d() and item.state | d(\"present\") != \"absent\")"))
    (task "Save dependent configuration on Ansible Controller"
      (ansible.builtin.template 
        (src "secret/icinga/dependent_config/inventory_hostname/configuration.json.j2")
        (dest (jinja "{{ secret + \"/icinga/dependent_config/\" + inventory_hostname + \"/configuration.json\" }}"))
        (mode "0644"))
      (become "False")
      (delegate_to "localhost"))
    (task "Register Icinga node in Icinga Director"
      (ansible.builtin.uri 
        (body_format "json")
        (headers 
          (Accept "application/json"))
        (method "POST")
        (body (jinja "{{ icinga__director_register_host_object }}"))
        (url (jinja "{{ icinga__director_register_api_url }}"))
        (user (jinja "{{ icinga__director_register_api_user }}"))
        (password (jinja "{{ icinga__director_register_api_password }}"))
        (status_code (list
            "201"
            "422"
            "500"))
        (force_basic_auth "True"))
      (register "icinga__register_director_host")
      (notify (list
          "Trigger Icinga Director configuration deployment"))
      (when "(icinga__director_enabled | bool and icinga__director_register | bool and (icinga__node_type != 'master' or (ansible_local.icinga_web.installed | d()) | bool))")
      (changed_when "icinga__register_director_host.status == 201")
      (tags (list
          "role::icinga:register"))
      (no_log (jinja "{{ debops__no_log | d(True) }}")))))
