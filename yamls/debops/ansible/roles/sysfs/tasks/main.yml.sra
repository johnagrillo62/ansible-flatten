(playbook "debops/ansible/roles/sysfs/tasks/main.yml"
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
        (name (jinja "{{ q(\"flattened\", (sysfs__base_packages
                              + sysfs__packages)) }}"))
        (state "present"))
      (register "sysfs__register_packages")
      (until "sysfs__register_packages is succeeded")
      (when "sysfs__enabled | bool"))
    (task "Check if the dependent configuration exists"
      (ansible.builtin.stat 
        (path (jinja "{{ secret + \"/sysfs/dependent_config/\" + inventory_hostname + \"/attributes.json\" }}")))
      (register "sysfs__register_dependent_attributes_file")
      (become "False")
      (delegate_to "localhost")
      (when "(sysfs__enabled | bool and ansible_local | d() and ansible_local.sysfs | d() and (ansible_local.sysfs.configured | d()) | bool)"))
    (task "Load the dependent configuration from Ansible Controller"
      (ansible.builtin.slurp 
        (src (jinja "{{ secret + \"/sysfs/dependent_config/\" + inventory_hostname + \"/attributes.json\" }}")))
      (register "sysfs__register_dependent_attributes")
      (become "False")
      (delegate_to "localhost")
      (when "(sysfs__enabled | bool and ansible_local | d() and ansible_local.sysfs | d() and (ansible_local.sysfs.configured | d()) | bool and sysfs__register_dependent_attributes_file.stat.exists | bool)"))
    (task "Remove sysfs configuration files if requested"
      (ansible.builtin.file 
        (path "/etc/sysfs.d/" (jinja "{{ item.filename | d(item.name | replace(\"/\", \"_\")) }}") ".conf")
        (state "absent"))
      (with_items (jinja "{{ sysfs__combined_attributes | debops.debops.parse_kv_items }}"))
      (notify (list
          "Restart sysfsutils"))
      (when "(sysfs__enabled | bool and item.name | d() and item.state | d('present') == 'absent')"))
    (task "Generate sysfs configuration files"
      (ansible.builtin.template 
        (src "etc/sysfs.d/attribute.conf.j2")
        (dest "/etc/sysfs.d/" (jinja "{{ item.filename | d(item.name | replace(\"/\", \"_\")) }}") ".conf")
        (owner "root")
        (group "root")
        (mode "0644"))
      (with_items (jinja "{{ sysfs__combined_attributes | debops.debops.parse_kv_items }}"))
      (notify (list
          "Restart sysfsutils"))
      (when "(sysfs__enabled | bool and item.name | d() and item.state | d('present') not in ['defined', 'absent'])"))
    (task "Make sure that Ansible local facts directory exists"
      (ansible.builtin.file 
        (path "/etc/ansible/facts.d")
        (state "directory")
        (owner "root")
        (group "root")
        (mode "0755")))
    (task "Save sysfs local facts"
      (ansible.builtin.template 
        (src "etc/ansible/facts.d/sysfs.fact.j2")
        (dest "/etc/ansible/facts.d/sysfs.fact")
        (owner "root")
        (group "root")
        (mode "0755"))
      (notify (list
          "Refresh host facts"))
      (tags (list
          "meta::facts")))
    (task "Update Ansible facts if they were modified"
      (ansible.builtin.meta "flush_handlers"))
    (task "Save dependent configuration on Ansible Controller"
      (ansible.builtin.template 
        (src "secret/sysfs/dependent_config/inventory_hostname/attributes.json.j2")
        (dest (jinja "{{ secret + \"/sysfs/dependent_config/\" + inventory_hostname + \"/attributes.json\" }}"))
        (mode "0644"))
      (become "False")
      (delegate_to "localhost")
      (when "sysfs__enabled | bool"))))
