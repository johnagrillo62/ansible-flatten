(playbook "debops/ansible/roles/kmod/tasks/main.yml"
  (tasks
    (task "Import custom Ansible plugins"
      (ansible.builtin.import_role 
        (name "ansible_plugins")))
    (task "Import DebOps global handlers"
      (ansible.builtin.import_role 
        (name "global_handlers")))
    (task "Check if modprobe is available"
      (ansible.builtin.stat 
        (path "/sbin/modprobe"))
      (register "kmod__register_modprobe"))
    (task "Install required packages"
      (ansible.builtin.package 
        (name (jinja "{{ q(\"flattened\", (kmod__base_packages
                              + kmod__packages)) }}"))
        (state "present"))
      (register "kmod__register_packages")
      (until "kmod__register_packages is succeeded"))
    (task "Make sure that Ansible local facts directory exists"
      (ansible.builtin.file 
        (path "/etc/ansible/facts.d")
        (state "directory")
        (owner "root")
        (group "root")
        (mode "0755")))
    (task "Save kmod local facts"
      (ansible.builtin.template 
        (src "etc/ansible/facts.d/kmod.fact.j2")
        (dest "/etc/ansible/facts.d/kmod.fact")
        (owner "root")
        (group "root")
        (mode "0755"))
      (notify (list
          "Refresh host facts"))
      (tags (list
          "meta::facts")))
    (task "Update Ansible facts if they were modified"
      (ansible.builtin.meta "flush_handlers"))
    (task "Configure kernel modules"
      (ansible.builtin.include_tasks "modprobe.yml")
      (loop_control 
        (loop_var "module"))
      (with_items (jinja "{{ kmod__combined_modules | debops.debops.parse_kv_items }}"))
      (when "kmod__enabled | bool"))
    (task "Remove module load configuration"
      (ansible.builtin.file 
        (dest "/etc/modules-load.d/" (jinja "{{ item.filename | d(item.name | replace(\"_\", \"-\") + \".conf\") }}"))
        (state "absent"))
      (with_items (jinja "{{ kmod__combined_load | debops.debops.parse_kv_items }}"))
      (when "kmod__enabled | bool and ansible_service_mgr == 'systemd' and item.name | d() and item.state | d('present') == 'absent'"))
    (task "Configure module loading at boot"
      (ansible.builtin.template 
        (src "etc/modules-load.d/module.conf.j2")
        (dest "/etc/modules-load.d/" (jinja "{{ item.filename | d(item.name | replace(\"_\", \"-\") + \".conf\") }}"))
        (owner "root")
        (group "root")
        (mode "0644"))
      (with_items (jinja "{{ kmod__combined_load | debops.debops.parse_kv_items }}"))
      (when "kmod__enabled | bool and ansible_service_mgr == 'systemd' and item.name | d() and item.state | d('present') not in ['absent', 'ignore']"))
    (task "Manage module loading in /etc/modules"
      (ansible.builtin.lineinfile 
        (dest "/etc/modules")
        (regexp "^" (jinja "{{ item.name }}"))
        (line (jinja "{{ item.name }}"))
        (state (jinja "{{ item.state }}"))
        (mode "0644"))
      (loop (jinja "{{ kmod__combined_load | debops.debops.parse_kv_items }}"))
      (loop_control 
        (label (jinja "{{ {\"name\": item.name, \"state\": item.state | d(\"present\")} }}")))
      (when "kmod__enabled | bool and ansible_service_mgr != 'systemd' and item.name | d() and item.state | d('present') in ['present', 'absent']"))
    (task "Load missing kernel modules enabled at boot"
      (community.general.modprobe 
        (name (jinja "{{ item.name }}"))
        (state "present"))
      (with_items (jinja "{{ kmod__combined_load | debops.debops.parse_kv_items }}"))
      (notify (list
          "Refresh host facts"))
      (when "kmod__enabled | bool and item.name | d() and item.state | d('present') not in ['config', 'absent', 'ignore'] and item.modules is undefined and ansible_local.kmod.modules | d() and item.name not in ansible_local.kmod.modules"))
    (task "Update Ansible facts if modules were loaded"
      (ansible.builtin.meta "flush_handlers"))))
