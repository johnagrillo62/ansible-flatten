(playbook "debops/ansible/roles/avahi/tasks/main.yml"
  (tasks
    (task "Import DebOps global handlers"
      (ansible.builtin.import_role 
        (name "global_handlers")))
    (task "Create systemd-resolved configuration directory"
      (ansible.builtin.file 
        (path "/etc/systemd/resolved.conf.d")
        (state "directory")
        (mode "0755"))
      (when "(ansible_service_mgr == 'systemd' and (ansible_local.resolved.installed | d()) | bool)"))
    (task "Disable MulticastDNS support in systemd-resolved"
      (ansible.builtin.template 
        (src "etc/systemd/resolved.conf.d/avahi-mdns.conf.j2")
        (dest "/etc/systemd/resolved.conf.d/avahi-mdns.conf")
        (mode "0644"))
      (notify (list
          "Restart systemd-resolved service"))
      (when "(ansible_service_mgr == 'systemd' and (ansible_local.resolved.installed | d()) | bool)"))
    (task "Flush handlers when needed"
      (ansible.builtin.meta "flush_handlers"))
    (task "Make sure that Avahi config directory exists"
      (ansible.builtin.file 
        (path "/etc/avahi")
        (state "directory")
        (owner "root")
        (group "root")
        (mode "0755")))
    (task "Divert the avahi-daemon configuration"
      (debops.debops.dpkg_divert 
        (path "/etc/avahi/" (jinja "{{ item }}")))
      (loop (list
          "avahi-daemon.conf"
          "hosts"))
      (register "avahi__register_divert")
      (notify (list
          "Restart avahi-daemon")))
    (task "Configure avahi-daemon"
      (ansible.builtin.template 
        (src "etc/avahi/avahi-daemon.conf.j2")
        (dest "/etc/avahi/avahi-daemon.conf")
        (owner "root")
        (group "root")
        (mode "0644"))
      (notify (list
          "Restart avahi-daemon")))
    (task "Create a stub mDNS hosts configuration file"
      (ansible.builtin.file 
        (state "touch")
        (dest "/etc/avahi/hosts")
        (owner "root")
        (group "root")
        (mode "0644"))
      (when "avahi__register_divert is changed"))
    (task "Create avahi-daemon systemd override directory"
      (ansible.builtin.file 
        (path "/etc/systemd/system/avahi-daemon.service.d")
        (state "directory")
        (owner "root")
        (group "root")
        (mode "0755"))
      (when "ansible_service_mgr == 'systemd' and ansible_virtualization_type in ['lxc', 'docker'] and ansible_virtualization_role == 'guest'"))
    (task "Install avahi-daemon exec override on LXC guests"
      (ansible.builtin.template 
        (src "etc/systemd/system/avahi-daemon.service.d/exec-override.conf.j2")
        (dest "/etc/systemd/system/avahi-daemon.service.d/exec-override.conf")
        (owner "root")
        (group "root")
        (mode "0644"))
      (when "ansible_service_mgr == 'systemd' and ansible_virtualization_type in ['lxc', 'docker'] and ansible_virtualization_role == 'guest'"))
    (task "Install required packages"
      (ansible.builtin.package 
        (name (jinja "{{ q(\"flattened\", (avahi__base_packages
                              + avahi__packages)) }}"))
        (state "present"))
      (register "avahi__register_packages")
      (until "avahi__register_packages is succeeded"))
    (task "Manage advertisement of additional hosts over Avahi"
      (ansible.builtin.lineinfile 
        (dest "/etc/avahi/hosts")
        (regexp (jinja "{{ \"^\" + item.key + \"\\s+\" }}"))
        (line (jinja "{{ item.key }}") " " (jinja "{{ (item.value
                              if item.value.endswith(\".\" + avahi__domain)
                              else (item.value + \".\" + avahi__domain)) }}"))
        (state "present")
        (mode "0644"))
      (with_dict (jinja "{{ avahi__hosts | combine(avahi__group_hosts) | combine(avahi__host_hosts) }}"))
      (when "item.key | d() and item.value | d()"))
    (task "Configure Avahi CNAME aliases"
      (ansible.builtin.include_tasks "avahi_alias.yml")
      (when "avahi__alias_enabled | bool")
      (tags (list
          "role::avahi:alias")))
    (task "Remove Avahi services if requested"
      (ansible.builtin.file 
        (path "/etc/avahi/services/" (jinja "{{ item.value.filename | d(item.key) }}") ".service")
        (state "absent"))
      (with_dict (jinja "{{ avahi__combined_services }}"))
      (when "item.value.filename | d(item.key) and item.value.state | d('present') == 'absent'")
      (tags (list
          "role::avahi:alias"
          "role::avahi:services")))
    (task "Configure Avahi services"
      (ansible.builtin.template 
        (src "etc/avahi/services/avahi.service.j2")
        (dest "/etc/avahi/services/" (jinja "{{ item.value.filename | d(item.key) }}") ".service")
        (owner "root")
        (group "root")
        (mode "0644"))
      (with_dict (jinja "{{ avahi__combined_services }}"))
      (when "(item.value.filename | d(item.key) and item.value.state | d('present') != 'absent' and (item.value.services | d() or item.value.type | d()))")
      (tags (list
          "role::avahi:alias"
          "role::avahi:services")))
    (task "Ensure that the avahi-daemon service in in the desired state"
      (ansible.builtin.service 
        (name "avahi-daemon")
        (enabled (jinja "{{ avahi__enabled | bool }}"))
        (state (jinja "{{ \"started\" if (avahi__enabled | bool) else \"stopped\" }}"))))
    (task "Make sure that Ansible local facts directory exists"
      (ansible.builtin.file 
        (path "/etc/ansible/facts.d")
        (state "directory")
        (mode "0755")))
    (task "Save Avahi local facts"
      (ansible.builtin.template 
        (src "etc/ansible/facts.d/avahi.fact.j2")
        (dest "/etc/ansible/facts.d/avahi.fact")
        (mode "0755"))
      (notify (list
          "Refresh host facts"))
      (tags (list
          "meta::facts")))
    (task "Update Ansible facts if they were modified"
      (ansible.builtin.meta "flush_handlers"))))
