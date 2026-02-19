(playbook "debops/ansible/roles/avahi/tasks/avahi_alias.yml"
  (tasks
    (task "Install avahi-alias script"
      (ansible.builtin.copy 
        (src "usr/local/sbin/avahi-alias")
        (dest (jinja "{{ avahi__alias_install_path }}") "/avahi-alias")
        (mode "0755"))
      (register "avahi__register_alias_script"))
    (task "Install avahi-alias.service"
      (ansible.builtin.template 
        (src "etc/systemd/system/avahi-alias.service.j2")
        (dest "/etc/systemd/system/avahi-alias.service")
        (owner "root")
        (group "root")
        (mode "0644"))
      (register "avahi__register_alias_service"))
    (task "Make sure that the CNAME alias file exists"
      (ansible.builtin.file 
        (path (jinja "{{ avahi__alias_config_file }}"))
        (state "touch")
        (owner "root")
        (group "root")
        (mode "0644"))
      (when "avahi__register_alias_script is changed"))
    (task "Manage list of CNAME entries"
      (ansible.builtin.lineinfile 
        (dest (jinja "{{ avahi__alias_config_file }}"))
        (regexp (jinja "{{ \"^\" + (item.value.cname
                       if item.value.cname.endswith(\".\" + avahi__domain)
                       else (item.value.cname + \".\" + avahi__domain)) + \"$\" }}"))
        (line (jinja "{{ (item.value.cname
               if item.value.cname.endswith(\".\" + avahi__domain)
               else (item.value.cname + \".\" + avahi__domain)) }}"))
        (state (jinja "{{ \"present\"
               if item.value.cname_state | d(item.value.state | d(\"present\")) != \"absent\"
               else \"absent\" }}"))
        (mode "0644"))
      (with_dict (jinja "{{ avahi__combined_services }}"))
      (register "avahi__register_aliases")
      (when "item.value.cname | d()"))
    (task "Manage avahi-alias.service"
      (ansible.builtin.systemd 
        (name "avahi-alias.service")
        (enabled (jinja "{{ True if avahi__register_alias_script is changed else omit }}"))
        (daemon_reload (jinja "{{ True if (avahi__register_alias_script is changed or
                                avahi__register_alias_service is changed) else omit }}"))
        (state (jinja "{{ \"restarted\" if (avahi__register_alias_script is changed or
                               avahi__register_alias_service is changed or
                               avahi__register_aliases is changed) else omit }}")))
      (when "ansible_service_mgr == 'systemd'"))))
