(playbook "debops/ansible/roles/dnsmasq/tasks/main.yml"
  (tasks
    (task "Import custom Ansible plugins"
      (ansible.builtin.import_role 
        (name "ansible_plugins")))
    (task "Import DebOps global handlers"
      (ansible.builtin.import_role 
        (name "global_handlers")))
    (task "Install required packages"
      (ansible.builtin.package 
        (name (jinja "{{ q(\"flattened\", (dnsmasq__base_packages + dnsmasq__packages)) }}"))
        (state "present"))
      (register "dnsmasq__register_packages")
      (until "dnsmasq__register_packages is succeeded"))
    (task "Make sure Ansible fact directory exists"
      (ansible.builtin.file 
        (path "/etc/ansible/facts.d")
        (state "directory")
        (owner "root")
        (group "root")
        (mode "0755")))
    (task "Generate dnsmasq Ansible local facts"
      (ansible.builtin.template 
        (src "etc/ansible/facts.d/dnsmasq.fact.j2")
        (dest "/etc/ansible/facts.d/dnsmasq.fact")
        (owner "root")
        (group "root")
        (mode "0755")
        (unsafe_writes (jinja "{{ True if (core__unsafe_writes | d(ansible_local.core.unsafe_writes | d()) | bool) else omit }}")))
      (notify (list
          "Refresh host facts"))
      (tags (list
          "meta::facts")))
    (task "Reload facts if they were modified"
      (ansible.builtin.meta "flush_handlers"))
    (task "Make sure TFTP root directory exists"
      (ansible.builtin.file 
        (path (jinja "{{ dnsmasq__boot_tftp_root }}"))
        (state "directory")
        (owner "root")
        (group "root")
        (mode "0755"))
      (when "dnsmasq__boot_enabled | bool"))
    (task "Remove dnsmasq configuration if requested"
      (ansible.builtin.file 
        (path "/etc/dnsmasq.d/" (jinja "{{ item.filename | d(item.name | regex_replace(\"\\.conf$\", \"\") + \".conf\") }}"))
        (state "absent"))
      (with_items (jinja "{{ dnsmasq__combined_configuration | debops.debops.parse_kv_items }}"))
      (notify (list
          "Test and restart dnsmasq"))
      (when "(item.name | d() and item.state | d('present') == 'absent')"))
    (task "Generate dnsmasq configuration"
      (ansible.builtin.template 
        (src "etc/dnsmasq.d/template.conf.j2")
        (dest "/etc/dnsmasq.d/" (jinja "{{ item.filename | d(item.name | regex_replace(\".conf$\", \"\") + \".conf\") }}"))
        (owner "root")
        (group "root")
        (mode "0644"))
      (with_items (jinja "{{ dnsmasq__combined_configuration | debops.debops.parse_kv_items }}"))
      (notify (list
          "Test and restart dnsmasq"))
      (when "(item.name | d() and item.state | d('present') not in ['absent', 'ignore', 'init'])"))
    (task "Remove DHCP host configuration and DNS records if requested"
      (ansible.builtin.file 
        (path "/etc/dnsmasq.d/" (jinja "{{ dnsmasq__dhcp_dns_filename }}"))
        (state "absent"))
      (notify (list
          "Test and restart dnsmasq"))
      (when "not dnsmasq__dhcp_hosts | d() and not dnsmasq__dns_records | d()"))
    (task "Generate DHCP host configuration and DNS records"
      (ansible.builtin.template 
        (src "etc/dnsmasq.d/dhcp-dns-options.conf.j2")
        (dest "/etc/dnsmasq.d/" (jinja "{{ dnsmasq__dhcp_dns_filename }}"))
        (owner "root")
        (group "root")
        (mode "0644"))
      (notify (list
          "Test and restart dnsmasq"))
      (when "dnsmasq__dhcp_hosts | d() or dnsmasq__dns_records | d()"))
    (task "Divert original dnsmasq environment file"
      (debops.debops.dpkg_divert 
        (path "/etc/default/dnsmasq"))
      (notify (list
          "Test and restart dnsmasq")))
    (task "Configure dnsmasq environment file"
      (ansible.builtin.template 
        (src "etc/default/dnsmasq.j2")
        (dest "/etc/default/dnsmasq")
        (owner "root")
        (group "root")
        (mode "0644")
        (unsafe_writes (jinja "{{ True if (core__unsafe_writes | d(ansible_local.core.unsafe_writes | d()) | bool) else omit }}")))
      (notify (list
          "Test and restart dnsmasq")))
    (task "Configure custom nameservers in resolvconf"
      (ansible.builtin.template 
        (src "etc/resolvconf/upstream.conf.j2")
        (dest "/etc/resolvconf/upstream.conf")
        (owner "root")
        (group "root")
        (mode "0644")
        (unsafe_writes (jinja "{{ True if (core__unsafe_writes | d(ansible_local.core.unsafe_writes | d()) | bool) else omit }}")))
      (notify (list
          "Test and restart dnsmasq"))
      (when "dnsmasq__nameservers | d()"))))
