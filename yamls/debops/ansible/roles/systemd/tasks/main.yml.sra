(playbook "debops/ansible/roles/systemd/tasks/main.yml"
  (tasks
    (task "Import DebOps global handlers"
      (ansible.builtin.import_role 
        (name "global_handlers")))
    (task "Make sure that Ansible local facts directory exists"
      (ansible.builtin.file 
        (path "/etc/ansible/facts.d")
        (state "directory")
        (mode "0755")))
    (task "Save systemd local facts"
      (ansible.builtin.template 
        (src "etc/ansible/facts.d/systemd.fact.j2")
        (dest "/etc/ansible/facts.d/systemd.fact")
        (mode "0755"))
      (notify (list
          "Refresh host facts"))
      (tags (list
          "meta::facts")))
    (task "Update Ansible facts if they were modified"
      (ansible.builtin.meta "flush_handlers"))
    (task "Remove systemd configuuration if requested"
      (ansible.builtin.file 
        (path (jinja "{{ \"/etc/systemd/\" + item + \".d/ansible.conf\" }}"))
        (state "absent"))
      (loop (list
          "system.conf"
          "user.conf"
          "logind.conf"))
      (notify (list
          "Reload systemd daemon"))
      (when "systemd__enabled | bool and systemd__deploy_state == 'absent'"))
    (task "Create systemd configuration directories"
      (ansible.builtin.file 
        (path (jinja "{{ \"/etc/systemd/\" + item + \".d\" }}"))
        (state "directory")
        (mode "0755"))
      (loop (list
          "system.conf"
          "user.conf"
          "logind.conf"))
      (when "systemd__enabled | bool and systemd__deploy_state != 'absent'"))
    (task "Generate systemd configuration"
      (ansible.builtin.template 
        (src (jinja "{{ \"etc/systemd/\" + item + \".d/ansible.conf.j2\" }}"))
        (dest (jinja "{{ \"/etc/systemd/\" + item + \".d/ansible.conf\" }}"))
        (mode "0644"))
      (loop (list
          "system.conf"
          "user.conf"
          "logind.conf"))
      (notify (list
          "Reload systemd daemon"))
      (when "systemd__enabled | bool and systemd__deploy_state != 'absent'"))
    (task "Remove system units if requested"
      (ansible.builtin.file 
        (path (jinja "{{ \"/etc/systemd/system/\" + item.name }}"))
        (state "absent"))
      (loop (jinja "{{ systemd__combined_units | flatten | debops.debops.parse_kv_items }}"))
      (loop_control 
        (label (jinja "{{ {\"name\": item.name, \"state\": item.state | d(\"present\")} }}")))
      (register "systemd__register_units_removed")
      (notify (list
          "Reload systemd daemon"))
      (when "systemd__enabled | bool and item.state | d(\"present\") == 'absent'"))
    (task "Remove system unit overrides if requested"
      (ansible.builtin.file 
        (path (jinja "{{ \"/etc/systemd/system/\" + item.name + \".d\" }}"))
        (state "absent"))
      (loop (jinja "{{ systemd__combined_units | flatten | debops.debops.parse_kv_items }}"))
      (loop_control 
        (label (jinja "{{ {\"name\": item.name, \"state\": item.state | d(\"present\")} }}")))
      (notify (list
          "Reload systemd daemon"))
      (when "systemd__enabled | bool and item.state | d(\"present\") == 'absent'"))
    (task "Create directories for system units"
      (ansible.builtin.file 
        (path (jinja "{{ \"/etc/systemd/system/\" + (item.name | dirname) }}"))
        (state "directory")
        (mode "0755"))
      (loop (jinja "{{ systemd__combined_units | flatten | debops.debops.parse_kv_items }}"))
      (loop_control 
        (label (jinja "{{ {\"name\": item.name, \"state\": item.state | d(\"present\")} }}")))
      (when "systemd__enabled | bool and item.raw | d() and item.state | d(\"present\") not in ['absent', 'ignore', 'init'] and (item.name | dirname).endswith('.d')"))
    (task "Generate system units"
      (ansible.builtin.template 
        (src "etc/systemd/system/template.j2")
        (dest (jinja "{{ \"/etc/systemd/system/\" + item.name }}"))
        (mode "0644"))
      (loop (jinja "{{ systemd__combined_units | flatten | debops.debops.parse_kv_items }}"))
      (loop_control 
        (label (jinja "{{ {\"name\": item.name, \"state\": item.state | d(\"present\")} }}")))
      (register "systemd__register_units_created")
      (notify (list
          "Reload systemd daemon"))
      (when "systemd__enabled | bool and item.raw | d() and item.state | d(\"present\") not in ['absent', 'ignore', 'init']"))
    (task "Remove user units if requested"
      (ansible.builtin.file 
        (path (jinja "{{ \"/etc/systemd/user/\" + item.name }}"))
        (state "absent"))
      (loop (jinja "{{ systemd__user_combined_units | flatten | debops.debops.parse_kv_items }}"))
      (loop_control 
        (label (jinja "{{ {\"name\": item.name, \"state\": item.state | d(\"present\")} }}")))
      (notify (list
          "Reload systemd daemon"))
      (when "systemd__enabled | bool and item.state | d(\"present\") == 'absent'"))
    (task "Remove user unit overrides if requested"
      (ansible.builtin.file 
        (path (jinja "{{ \"/etc/systemd/user/\" + item.name + \".d\" }}"))
        (state "absent"))
      (loop (jinja "{{ systemd__user_combined_units | flatten | debops.debops.parse_kv_items }}"))
      (loop_control 
        (label (jinja "{{ {\"name\": item.name, \"state\": item.state | d(\"present\")} }}")))
      (notify (list
          "Reload systemd daemon"))
      (when "systemd__enabled | bool and item.state | d(\"present\") == 'absent'"))
    (task "Create directories for user units"
      (ansible.builtin.file 
        (path (jinja "{{ \"/etc/systemd/user/\" + (item.name | dirname) }}"))
        (state "directory")
        (mode "0755"))
      (loop (jinja "{{ systemd__user_combined_units | flatten | debops.debops.parse_kv_items }}"))
      (loop_control 
        (label (jinja "{{ {\"name\": item.name, \"state\": item.state | d(\"present\")} }}")))
      (when "systemd__enabled | bool and item.raw | d() and item.state | d(\"present\") not in ['absent', 'ignore', 'init'] and (item.name | dirname).endswith('.d')"))
    (task "Generate user units"
      (ansible.builtin.template 
        (src "etc/systemd/user/template.j2")
        (dest (jinja "{{ \"/etc/systemd/user/\" + item.name }}"))
        (mode "0644"))
      (loop (jinja "{{ systemd__user_combined_units | flatten | debops.debops.parse_kv_items }}"))
      (loop_control 
        (label (jinja "{{ {\"name\": item.name, \"state\": item.state | d(\"present\")} }}")))
      (notify (list
          "Reload systemd daemon"))
      (when "systemd__enabled | bool and item.raw | d() and item.state | d(\"present\") not in ['absent', 'ignore', 'init']"))
    (task "Flush handlers when needed"
      (ansible.builtin.meta "flush_handlers"))
    (task "Configure system units"
      (ansible.builtin.systemd 
        (name (jinja "{{ item.name }}"))
        (enabled (jinja "{{ item.enabled | d(False if (item.masked | d() | bool) else True) }}"))
        (force (jinja "{{ item.force | d(omit) }}"))
        (masked (jinja "{{ item.masked | d(omit) }}"))
        (state (jinja "{{ item.state if (item.state in [\"reloaded\", \"restarted\", \"started\", \"stopped\"]) else omit }}")))
      (loop (jinja "{{ systemd__combined_units | flatten | debops.debops.parse_kv_items }}"))
      (loop_control 
        (label (jinja "{{ {\"name\": item.name, \"state\": item.state | d(\"present\")} }}")))
      (when "systemd__enabled | bool and item.state | d(\"present\") not in ['absent', 'ignore', 'init'] and not (item.name | dirname).endswith('.d')"))
    (task "Restart system units if modified"
      (ansible.builtin.systemd 
        (name (jinja "{{ item.restart }}"))
        (state "restarted"))
      (loop (jinja "{{ systemd__combined_units | flatten | debops.debops.parse_kv_items }}"))
      (loop_control 
        (label (jinja "{{ {\"restart\": item.restart | d()} }}")))
      (when "systemd__enabled | bool and item.restart | d() and item.state | d(\"present\") not in ['ignore', 'init'] and ((item.name in (systemd__register_units_removed.results | selectattr(\"changed\", \"true\") | map(attribute=\"item.name\") | list)) or (item.name in (systemd__register_units_created.results | selectattr(\"changed\", \"true\") | map(attribute=\"item.name\") | list)))"))
    (task "Configure user units"
      (ansible.builtin.systemd 
        (name (jinja "{{ item.name }}"))
        (enabled (jinja "{{ item.enabled | d(False if (item.masked | d() | bool) else True) }}"))
        (force (jinja "{{ item.force | d(omit) }}"))
        (masked (jinja "{{ item.masked | d(omit) }}"))
        (state (jinja "{{ item.state if (item.state in [\"reloaded\", \"restarted\", \"started\", \"stopped\"]) else omit }}"))
        (scope "global"))
      (loop (jinja "{{ systemd__user_combined_units | flatten | debops.debops.parse_kv_items }}"))
      (loop_control 
        (label (jinja "{{ {\"name\": item.name, \"state\": item.state | d(\"present\")} }}")))
      (when "systemd__enabled | bool and item.state | d(\"present\") not in ['absent', 'ignore', 'init'] and not (item.name | dirname).endswith('.d')"))))
