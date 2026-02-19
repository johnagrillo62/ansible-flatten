(playbook "debops/ansible/roles/rsyslog/tasks/main.yml"
  (tasks
    (task "Import custom Ansible plugins"
      (ansible.builtin.import_role 
        (name "ansible_plugins")))
    (task "Import DebOps global handlers"
      (ansible.builtin.import_role 
        (name "global_handlers")))
    (task "Manage rsyslog APT packages"
      (ansible.builtin.apt 
        (name (jinja "{{ (rsyslog__base_packages
               + (rsyslog__tls_packages if (rsyslog__pki | bool) else [])
               + rsyslog__packages) | flatten }}"))
        (state (jinja "{{ rsyslog__deploy_state }}"))
        (purge "True"))
      (register "rsyslog__register_packages")
      (until "rsyslog__register_packages is succeeded")
      (when "rsyslog__enabled | bool and ansible_pkg_mgr == 'apt'"))
    (task "Make sure that Ansible local facts directory exists"
      (ansible.builtin.file 
        (path "/etc/ansible/facts.d")
        (state "directory")
        (mode "0755"))
      (when "rsyslog__enabled | bool and rsyslog__deploy_state != 'absent'"))
    (task "Save rsyslog local facts"
      (ansible.builtin.template 
        (src "etc/ansible/facts.d/rsyslog.fact.j2")
        (dest "/etc/ansible/facts.d/rsyslog.fact")
        (mode "0755"))
      (notify (list
          "Refresh host facts"))
      (when "rsyslog__enabled | bool and rsyslog__deploy_state != 'absent'")
      (tags (list
          "meta::facts")))
    (task "Update Ansible facts if they were modified"
      (ansible.builtin.meta "flush_handlers"))
    (task "Create required system group"
      (ansible.builtin.group 
        (name (jinja "{{ rsyslog__group }}"))
        (state "present")
        (system "True"))
      (when "rsyslog__enabled | bool and rsyslog__deploy_state != 'absent' and rsyslog__unprivileged | bool and rsyslog__group != 'root'"))
    (task "Create required system user"
      (ansible.builtin.user 
        (name (jinja "{{ rsyslog__user }}"))
        (group (jinja "{{ rsyslog__group }}"))
        (groups (jinja "{{ rsyslog__append_groups | join(\",\") | default(omit) }}"))
        (append "True")
        (home (jinja "{{ rsyslog__home }}"))
        (shell "/bin/false")
        (state "present")
        (createhome "False")
        (system "True"))
      (when "rsyslog__enabled | bool and rsyslog__deploy_state != 'absent' and rsyslog__unprivileged | bool and rsyslog__user != 'root'"))
    (task "Fix directory permissions if needed"
      (ansible.builtin.file 
        (path "/var/spool/rsyslog")
        (owner (jinja "{{ rsyslog__user }}"))
        (group (jinja "{{ rsyslog__file_group }}"))
        (mode "0700"))
      (register "rsyslog__register_unprivileged_files")
      (when "rsyslog__enabled | bool and rsyslog__deploy_state != 'absent' and rsyslog__unprivileged | bool and rsyslog__user != 'root'"))
    (task "Update directory and file permissions"
      (ansible.builtin.shell "[ ! -d " (jinja "{{ rsyslog__home }}") " ] \\
  || ( [ \"$(stat -c '%G' " (jinja "{{ rsyslog__home }}") ")\" = \"" (jinja "{{ rsyslog__group }}") "\" ] \\
         || chown -v root:" (jinja "{{ rsyslog__group }}") " " (jinja "{{ rsyslog__home }}") " ; \\
       [ \"$(stat -c '%a' " (jinja "{{ rsyslog__home }}") ")\" = \"775\" ] \\
         || chmod -v 775 " (jinja "{{ rsyslog__home }}") " )
for i in " (jinja "{{ rsyslog__default_logfiles | join(\" \") }}") " ; do
  [ ! -f ${i} ] || \\
    ( [ \"$(stat -c '%U' ${i})\" = \"" (jinja "{{ rsyslog__file_owner }}") "\" ] \\
    || chown -v " (jinja "{{ rsyslog__file_owner }}") ":" (jinja "{{ rsyslog__file_group }}") " ${i} )
done
")
      (register "rsyslog__register_file_permissions")
      (when "rsyslog__enabled | bool and rsyslog__deploy_state != 'absent' and rsyslog__unprivileged | bool")
      (changed_when "rsyslog__register_file_permissions.stdout | d()")
      (notify (list
          "Check and restart rsyslogd")))
    (task "Create systemd-tmpfiles override"
      (ansible.builtin.copy 
        (dest "/etc/tmpfiles.d/rsyslog-var-log.conf")
        (mode "0755")
        (content "z " (jinja "{{ rsyslog__home }}") " 0775 root " (jinja "{{ rsyslog__group }}") " -"))
      (notify (list
          "Create temporary files"))
      (when "rsyslog__enabled | bool and rsyslog__deploy_state != 'absent' and ansible_service_mgr == \"systemd\" and rsyslog__unprivileged | bool and ansible_distribution == \"Debian\""))
    (task "Divert main rsyslog configuration file"
      (debops.debops.dpkg_divert 
        (path "/etc/rsyslog.conf")
        (state "present"))
      (notify (list
          "Check and restart rsyslogd"))
      (when "rsyslog__enabled | bool and rsyslog__deploy_state != 'absent' and ansible_pkg_mgr == 'apt'"))
    (task "Generate main rsyslog configuration"
      (ansible.builtin.template 
        (src "etc/rsyslog.conf.j2")
        (dest "/etc/rsyslog.conf")
        (mode "0644"))
      (notify (list
          "Check and restart rsyslogd"))
      (when "rsyslog__enabled | bool and rsyslog__deploy_state != 'absent'"))
    (task "Manage configuration file diversions"
      (debops.debops.dpkg_divert 
        (path (jinja "{{ \"/etc/rsyslog.d/\" + (item.divert_to | d(item.name)) }}"))
        (state (jinja "{{ \"present\"
               if (item.state | d(\"present\") not in [\"absent\", \"ignore\", \"init\"])
               else \"absent\" }}")))
      (loop (jinja "{{ rsyslog__combined_rules | flatten | debops.debops.parse_kv_items
            | selectattr(\"divert\", \"defined\") | list
            | selectattr(\"divert\", \"equalto\", True) | list }}"))
      (loop_control 
        (label (jinja "{{ {\"name\": item.name, \"state\": (item.state | d(\"present\"))} }}")))
      (notify (list
          "Check and restart rsyslogd"))
      (when "rsyslog__enabled | bool and rsyslog__deploy_state != 'absent'"))
    (task "Generate rsyslog configuration rules"
      (ansible.builtin.template 
        (src "etc/rsyslog.d/template.conf.j2")
        (dest (jinja "{{ \"/etc/rsyslog.d/\" + item.name }}"))
        (owner (jinja "{{ item.owner | d(\"root\") }}"))
        (group (jinja "{{ item.group | d(\"root\") }}"))
        (mode (jinja "{{ item.mode | d(\"0644\") }}")))
      (loop (jinja "{{ rsyslog__combined_rules | flatten | debops.debops.parse_kv_items }}"))
      (loop_control 
        (label (jinja "{{ {\"name\": item.name, \"state\": (item.state | d(\"present\"))} }}")))
      (when "(rsyslog__enabled | bool and rsyslog__deploy_state != 'absent' and item.state | d('present') not in ['absent', 'ignore', 'init'] and (item.options | d() or item.raw | d()))")
      (notify (list
          "Check and restart rsyslogd")))
    (task "Remove custom config files when requested"
      (ansible.builtin.file 
        (path (jinja "{{ \"/etc/rsyslog.d/\" + item.name }}"))
        (state "absent"))
      (loop (jinja "{{ rsyslog__combined_rules | flatten | debops.debops.parse_kv_items }}"))
      (loop_control 
        (label (jinja "{{ {\"name\": item.name, \"state\": (item.state | d(\"present\"))} }}")))
      (when "(rsyslog__enabled | bool and rsyslog__deploy_state != 'absent' and (item.divert is undefined or not item.divert | bool) and item.state | d('present') == 'absent')")
      (notify (list
          "Check and restart rsyslogd")))
    (task "Prepare cleanup during package removal"
      (ansible.builtin.import_role 
        (name "dpkg_cleanup"))
      (vars 
        (dpkg_cleanup__dependent_packages (list
            (jinja "{{ rsyslog__dpkg_cleanup__dependent_packages }}"))))
      (when "rsyslog__enabled | bool and rsyslog__deploy_state != 'absent'")
      (tags (list
          "role::dpkg_cleanup"
          "skip::dpkg_cleanup"
          "role::rsyslog:dpkg_cleanup")))))
