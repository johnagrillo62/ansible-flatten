(playbook "debops/ansible/roles/postfix/tasks/main.yml"
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
    (task "Install Postfix APT packages"
      (ansible.builtin.apt 
        (name (jinja "{{ (postfix__base_packages
             + postfix__dependent_packages
             + postfix__host_packages
             + postfix__group_packages
             + postfix__packages)
             | flatten }}"))
        (state "present")
        (install_recommends "False"))
      (register "postfix__register_packages")
      (until "postfix__register_packages is succeeded")
      (when "ansible_pkg_mgr == 'apt'")
      (tags (list
          "meta::provision")))
    (task "Purge other SMTP servers"
      (ansible.builtin.apt 
        (name (jinja "{{ postfix__purge_packages | flatten }}"))
        (state "absent")
        (purge "True"))
      (when "postfix__purge_packages | d() and ansible_pkg_mgr == 'apt'")
      (tags (list
          "meta::provision")))
    (task "Disable Postfix configuration in debconf"
      (ansible.builtin.debconf 
        (name "postfix")
        (question "postfix/main_mailer_type")
        (vtype "select")
        (value "No configuration"))
      (when "ansible_pkg_mgr == 'apt'"))
    (task "Make sure Ansible local facts directory exists"
      (ansible.builtin.file 
        (dest "/etc/ansible/facts.d")
        (state "directory")
        (owner "root")
        (group "root")
        (mode "0755")))
    (task "Configure Postfix local facts"
      (ansible.builtin.template 
        (src "etc/ansible/facts.d/postfix.fact.j2")
        (dest "/etc/ansible/facts.d/postfix.fact")
        (owner "root")
        (group "root")
        (mode "0755"))
      (notify (list
          "Refresh host facts"))
      (tags (list
          "meta::facts")))
    (task "Re-read local facts if they have been modified"
      (ansible.builtin.meta "flush_handlers"))
    (task "Configure /etc/mailname"
      (ansible.builtin.copy 
        (content (jinja "{{ postfix__mailname + '\\n' }}"))
        (dest "/etc/mailname")
        (owner "root")
        (group "root")
        (mode "0644"))
      (notify (list
          "Check postfix and reload")))
    (task "Install /etc/postfix/Makefile"
      (ansible.builtin.template 
        (src "etc/postfix/Makefile.j2")
        (dest "/etc/postfix/Makefile")
        (owner "root")
        (group "root")
        (mode "0644")))
    (task "Generate Postfix 'main.cf' configuration"
      (ansible.builtin.template 
        (src "etc/postfix/main.cf.j2")
        (dest "/etc/postfix/main.cf")
        (owner "root")
        (group "root")
        (mode "0644"))
      (notify (list
          "Check postfix and reload")))
    (task "Generate Postfix 'master.cf' configuration"
      (ansible.builtin.template 
        (src "etc/postfix/master.cf.j2")
        (dest "/etc/postfix/master.cf")
        (owner "root")
        (group "root")
        (mode "0644"))
      (notify (list
          "Check postfix and reload")))
    (task "Remove Postfix lookup tables"
      (ansible.builtin.file 
        (path "/etc/postfix/" (jinja "{{ item.name }}"))
        (state "absent"))
      (loop (jinja "{{ postfix__combined_lookup_tables | debops.debops.parse_kv_items }}"))
      (when "item.name | d() and item.state | d('present') == 'absent'")
      (notify (list
          "Process Postfix Makefile"
          "Check postfix and reload"))
      (no_log (jinja "{{ debops__no_log | d(item.no_log)
              | d(True if (item.mode | d(\"0644\") == \"0600\") else False) }}")))
    (task "Generate Postfix lookup tables"
      (ansible.builtin.template 
        (src "etc/postfix/lookup_table.j2")
        (dest "/etc/postfix/" (jinja "{{ item.name }}"))
        (owner (jinja "{{ item.owner | d(\"root\") }}"))
        (group (jinja "{{ item.group | d(\"postfix\") }}"))
        (mode (jinja "{{ item.mode | d(\"0640\") }}")))
      (loop (jinja "{{ postfix__combined_lookup_tables | debops.debops.parse_kv_items }}"))
      (notify (list
          "Process Postfix Makefile"
          "Check postfix and reload"))
      (when "item.name | d() and item.state | d('present') != 'absent'")
      (no_log (jinja "{{ debops__no_log | d(item.no_log)
              | d(True if (item.mode | d(\"0640\") in [\"0640\", \"0600\"])
                  else False) }}")))
    (task "Save dependent configuration on Ansible Controller"
      (ansible.builtin.template 
        (src (jinja "{{ \"secret/postfix/dependent_config/inventory_hostname/\" + item + \".j2\" }}"))
        (dest (jinja "{{ secret + \"/postfix/dependent_config/\" + inventory_hostname + \"/\" + item }}"))
        (mode "0644"))
      (become "False")
      (delegate_to "localhost")
      (with_items (list
          "maincf.json"
          "mastercf.json")))
    (task "Make sure that PKI hook directory exists"
      (ansible.builtin.file 
        (path (jinja "{{ postfix__pki_hook_path }}"))
        (state "directory")
        (owner "root")
        (group "root")
        (mode "0755"))
      (when "postfix__pki | bool"))
    (task "Manage PKI postfix hook"
      (ansible.builtin.template 
        (src "etc/pki/hooks/postfix.j2")
        (dest (jinja "{{ postfix__pki_hook_path + \"/\" + postfix__pki_hook_name }}"))
        (owner "root")
        (group "root")
        (mode "0755"))
      (when "postfix__pki | bool"))
    (task "Ensure the PKI postfix hook is absent"
      (ansible.builtin.file 
        (path (jinja "{{ postfix__pki_hook_path + \"/\" + postfix__pki_hook_name }}"))
        (state "absent"))
      (when "not (postfix__pki | bool)"))))
