(playbook "debops/ansible/roles/lldpd/tasks/main.yml"
  (tasks
    (task "Import custom Ansible plugins"
      (ansible.builtin.import_role 
        (name "ansible_plugins")))
    (task "Import DebOps global handlers"
      (ansible.builtin.import_role 
        (name "global_handlers")))
    (task "Install required packages"
      (ansible.builtin.package 
        (name (jinja "{{ q(\"flattened\", (lldpd__base_packages
                              + lldpd__packages)) }}"))
        (state "present"))
      (register "lldpd__register_packages")
      (until "lldpd__register_packages is succeeded")
      (when "lldpd__enabled | bool"))
    (task "Make sure that Ansible local facts directory exists"
      (ansible.builtin.file 
        (path "/etc/ansible/facts.d")
        (state "directory")
        (mode "0755"))
      (when "lldpd__enabled | bool"))
    (task "Save lldpd local facts"
      (ansible.builtin.template 
        (src "etc/ansible/facts.d/lldpd.fact.j2")
        (dest "/etc/ansible/facts.d/lldpd.fact")
        (mode "0755"))
      (notify (list
          "Refresh host facts"))
      (when "lldpd__enabled | bool")
      (tags (list
          "meta::facts")))
    (task "Update Ansible facts if they were modified"
      (ansible.builtin.meta "flush_handlers"))
    (task "Divert daemon configuration file if requested"
      (debops.debops.dpkg_divert 
        (path "/etc/default/lldpd")
        (state (jinja "{{ \"present\"
               if ((lldpd__default_daemon_arguments
                    + lldpd__daemon_arguments) | flatten) | d()
               else \"absent\" }}"))
        (delete "True"))
      (notify (list
          "Restart lldpd"))
      (when "lldpd__enabled | bool"))
    (task "Generate daemon environment configuration"
      (ansible.builtin.template 
        (src "etc/default/lldpd.j2")
        (dest "/etc/default/lldpd")
        (mode "0644"))
      (notify (list
          "Restart lldpd"))
      (when "lldpd__enabled | bool and (lldpd__default_daemon_arguments + lldpd__daemon_arguments) | flatten | d()"))
    (task "Remove lldpd configuration files if requested"
      (ansible.builtin.file 
        (path (jinja "{{ \"/etc/lldpd.d/\" + item.name + \".conf\" }}"))
        (state "absent"))
      (loop (jinja "{{ lldpd__combined_configuration | debops.debops.parse_kv_items }}"))
      (loop_control 
        (label (jinja "{{ {\"name\": item.name, \"state\": item.state | d(\"present\")} }}")))
      (notify (list
          "Restart lldpd"))
      (when "lldpd__enabled | bool and item.state | d('present') in ['absent']"))
    (task "Generate lldpd configuration files"
      (ansible.builtin.template 
        (src "etc/lldpd.d/template.conf.j2")
        (dest (jinja "{{ \"/etc/lldpd.d/\" + item.name + \".conf\" }}"))
        (mode "0644"))
      (loop (jinja "{{ lldpd__combined_configuration | debops.debops.parse_kv_items }}"))
      (loop_control 
        (label (jinja "{{ {\"name\": item.name, \"state\": item.state | d(\"present\")} }}")))
      (notify (list
          "Restart lldpd"))
      (when "lldpd__enabled | bool and item.state | d('present') not in ['absent', 'init', 'ignore']"))))
