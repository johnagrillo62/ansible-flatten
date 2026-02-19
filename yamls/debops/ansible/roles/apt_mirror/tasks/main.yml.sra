(playbook "debops/ansible/roles/apt_mirror/tasks/main.yml"
  (tasks
    (task "Import DebOps global handlers"
      (ansible.builtin.import_role 
        (name "global_handlers")))
    (task "Install required packages"
      (ansible.builtin.package 
        (name (jinja "{{ (apt_mirror__base_packages + apt_mirror__packages) | flatten }}"))
        (state "present"))
      (register "apt_mirror__register_install")
      (until "apt_mirror__register_install is succeeded"))
    (task "Get list of dpkg-stateoverride paths"
      (ansible.builtin.shell "set -o nounset -o pipefail -o errexit && dpkg-statoverride --list | awk '{print $4}'
")
      (args 
        (executable "bash"))
      (register "apt_mirror__register_statoverride")
      (changed_when "False")
      (check_mode "False"))
    (task "Fix permissions for apt-mirror spool directory"
      (ansible.builtin.command "dpkg-statoverride --update --add " (jinja "{{ apt_mirror__user }}") " " (jinja "{{ apt_mirror__group }}") " 0750 /var/spool/apt-mirror/var
")
      (register "apt_mirror__register_statoverride_set")
      (changed_when "apt_mirror__register_statoverride_set.changed | bool")
      (when "\"/var/spool/apt-mirror/var\" not in apt_mirror__register_statoverride.stdout_lines"))
    (task "Make sure that Ansible local facts directory exists"
      (ansible.builtin.file 
        (path "/etc/ansible/facts.d")
        (state "directory")
        (mode "0755")))
    (task "Save apt_mirror local facts"
      (ansible.builtin.template 
        (src "etc/ansible/facts.d/apt_mirror.fact.j2")
        (dest "/etc/ansible/facts.d/apt_mirror.fact")
        (mode "0755"))
      (notify (list
          "Refresh host facts"))
      (tags (list
          "meta::facts")))
    (task "Update Ansible facts if they were modified"
      (ansible.builtin.meta "flush_handlers"))
    (task "Divert the original apt-mirror configuration"
      (debops.debops.dpkg_divert 
        (path (jinja "{{ item }}"))
        (state "present"))
      (loop (list
          "/etc/apt/mirror.list"
          "/etc/cron.d/apt-mirror"))
      (when "ansible_pkg_mgr == 'apt'"))
    (task "Remove apt-mirror configuration if requested"
      (ansible.builtin.file 
        (path (jinja "{{ \"/etc/apt/\" + (item.filename | d(\"mirror.\" + item.name + \".list\")) }}"))
        (state "absent"))
      (loop (jinja "{{ apt_mirror__combined_configuration | flatten
            | debops.debops.parse_kv_items(merge_keys=[\"sources\"]) }}"))
      (loop_control 
        (label (jinja "{{ {\"name\": item.name, \"state\": item.state | d(\"present\")} }}")))
      (when "item.state | d('present') == 'absent'"))
    (task "Generate apt-mirror configuration files"
      (ansible.builtin.template 
        (src "etc/apt/mirror.list.j2")
        (dest (jinja "{{ \"/etc/apt/\" + (item.filename | d(\"mirror.\" + item.name + \".list\")) }}"))
        (owner (jinja "{{ apt_mirror__user }}"))
        (group (jinja "{{ apt_mirror__group }}"))
        (mode "0640"))
      (loop (jinja "{{ apt_mirror__combined_configuration | flatten
            | debops.debops.parse_kv_items(defaults={\"options\": (apt_mirror__default_options | debops.debops.parse_kv_config)},
                                           merge_keys=[\"sources\"]) }}"))
      (loop_control 
        (label (jinja "{{ {\"name\": item.name, \"state\": item.state | d(\"present\")} }}")))
      (when "item.state | d('present') not in [ 'absent', 'ignore', 'init' ]"))
    (task "Create data directories for separate mirror instances"
      (ansible.builtin.file 
        (path (jinja "{{ \"/var/spool/apt-mirror/var/var.\" + item.name }}"))
        (owner (jinja "{{ apt_mirror__user }}"))
        (group (jinja "{{ apt_mirror__group }}"))
        (mode "0750")
        (state "directory"))
      (loop (jinja "{{ apt_mirror__combined_configuration | flatten
            | debops.debops.parse_kv_items(defaults={\"options\": (apt_mirror__default_options | debops.debops.parse_kv_config)},
                                           merge_keys=[\"sources\"]) }}"))
      (loop_control 
        (label (jinja "{{ {\"name\": item.name, \"state\": item.state | d(\"present\")} }}")))
      (when "item.state | d('present') not in [ 'absent', 'ignore', 'init' ]"))
    (task "Create postmirror.sh script for separate mirror instances"
      (ansible.builtin.file 
        (path (jinja "{{ \"/var/spool/apt-mirror/var/var.\" + item.name + \"/postmirror.sh\" }}"))
        (owner (jinja "{{ apt_mirror__user }}"))
        (group (jinja "{{ apt_mirror__group }}"))
        (mode "0755")
        (state "touch")
        (modification_time "preserve")
        (access_time "preserve"))
      (loop (jinja "{{ apt_mirror__combined_configuration | flatten
            | debops.debops.parse_kv_items(defaults={\"options\": (apt_mirror__default_options | debops.debops.parse_kv_config)},
                                           merge_keys=[\"sources\"]) }}"))
      (loop_control 
        (label (jinja "{{ {\"name\": item.name, \"state\": item.state | d(\"present\")} }}")))
      (when "item.state | d('present') not in [ 'absent', 'ignore', 'init' ]"))
    (task "Generate cron configuration for apt-mirror"
      (ansible.builtin.template 
        (src "etc/cron.d/apt-mirror.j2")
        (dest "/etc/cron.d/apt-mirror")
        (mode "0644")))))
