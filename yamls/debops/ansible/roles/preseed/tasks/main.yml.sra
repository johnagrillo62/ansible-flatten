(playbook "debops/ansible/roles/preseed/tasks/main.yml"
  (tasks
    (task "Import custom Ansible plugins"
      (ansible.builtin.import_role 
        (name "ansible_plugins")))
    (task "Import DebOps secret role"
      (ansible.builtin.import_role 
        (name "secret")))
    (task "Remove configuration directories if requested"
      (ansible.builtin.file 
        (path (jinja "{{ preseed__www + \"/\" + item.flavor + \"/d-i/\" + item.release }}"))
        (state "absent"))
      (loop (jinja "{{ preseed__combined_definitions | debops.debops.parse_kv_items }}"))
      (loop_control 
        (label (jinja "{{ {\"name\": item.name, \"state\": item.state, \"flavor\": item.flavor, \"release\": item.release} }}")))
      (when "item.state | d('present') in ['absent']"))
    (task "Create configuration directories"
      (ansible.builtin.file 
        (path (jinja "{{ preseed__www + \"/\" + item.flavor + \"/d-i/\" + item.release }}"))
        (state "directory")
        (mode "0755"))
      (loop (jinja "{{ preseed__combined_definitions | debops.debops.parse_kv_items }}"))
      (loop_control 
        (label (jinja "{{ {\"name\": item.name, \"state\": item.state, \"flavor\": item.flavor, \"release\": item.release} }}")))
      (when "item.state | d('present') not in ['absent', 'ignore', 'init']"))
    (task "Generate Preseed configuration files"
      (ansible.builtin.template 
        (src "srv/www/sites/debian-preseed/public/preseed.cfg.j2")
        (dest (jinja "{{ preseed__www + \"/\" + item.flavor + \"/d-i/\"
              + item.release + \"/preseed.cfg\" }}"))
        (owner "root")
        (group "www-data")
        (mode "0640"))
      (loop (jinja "{{ preseed__combined_definitions
            | debops.debops.parse_kv_items(defaults={\"options\": preseed__combined_configuration
                                                                | debops.debops.parse_kv_config}) }}"))
      (loop_control 
        (label (jinja "{{ {\"name\": item.name, \"state\": item.state, \"flavor\": item.flavor, \"release\": item.release} }}")))
      (when "item.state | d('present') not in ['absent', 'ignore', 'init']"))
    (task "Generate postinst scripts"
      (ansible.builtin.template 
        (src "srv/www/sites/debian-preseed/public/postinst.sh.j2")
        (dest (jinja "{{ preseed__www + \"/\" + item.flavor + \"/d-i/\"
              + item.release + \"/postinst.sh\" }}"))
        (owner "root")
        (group "www-data")
        (mode "0640"))
      (loop (jinja "{{ preseed__combined_definitions
            | debops.debops.parse_kv_items(defaults={\"options\": preseed__combined_configuration
                                                                | debops.debops.parse_kv_config}) }}"))
      (loop_control 
        (label (jinja "{{ {\"name\": item.name, \"state\": item.state, \"flavor\": item.flavor, \"release\": item.release} }}")))
      (when "item.state | d('present') not in ['absent', 'ignore', 'init']"))
    (task "Make sure that Ansible local facts directory exists"
      (ansible.builtin.file 
        (path "/etc/ansible/facts.d")
        (state "directory")
        (mode "0755")))
    (task "Save Preseed local facts"
      (ansible.builtin.template 
        (src "etc/ansible/facts.d/preseed.fact.j2")
        (dest "/etc/ansible/facts.d/preseed.fact")
        (mode "0755"))
      (notify (list
          "Refresh host facts"))
      (tags (list
          "meta::facts")))
    (task "Update Ansible facts if they were modified"
      (ansible.builtin.meta "flush_handlers"))))
