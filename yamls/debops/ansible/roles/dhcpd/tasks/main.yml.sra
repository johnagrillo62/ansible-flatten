(playbook "debops/ansible/roles/dhcpd/tasks/main.yml"
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
    (task "Install ISC DHCP packages"
      (ansible.builtin.package 
        (name (jinja "{{ (dhcpd__base_packages + dhcpd__packages) | flatten }}"))
        (state "present"))
      (register "dhcpd__register_packages")
      (until "dhcpd__register_packages is succeeded"))
    (task "Divert original configuration"
      (debops.debops.dpkg_divert 
        (path (jinja "{{ item }}")))
      (with_items (list
          "/etc/default/isc-dhcp-server"
          "/etc/dhcp/dhcpd.conf"
          "/etc/dhcp/dhcpd6.conf")))
    (task "Write configuration includes"
      (ansible.builtin.template 
        (src "etc/dhcp/ansible_" (jinja "{{ item }}") ".conf.j2")
        (dest "/etc/dhcp/ansible_" (jinja "{{ item }}") ".conf")
        (mode "0644"))
      (with_items (list
          "failovers"
          "ipxe"
          "zones"))
      (notify (list
          "Restart isc-dhcp-server")))
    (task "Store secret keys"
      (ansible.builtin.template 
        (src "etc/dhcp/ansible_keys.conf.j2")
        (dest "/etc/dhcp/ansible_keys.conf")
        (mode "0600"))
      (notify (list
          "Restart isc-dhcp-server")))
    (task "Configure dhcpd.conf and dhcpd6.conf"
      (ansible.builtin.template 
        (src "etc/dhcp/dhcpd.conf.j2")
        (dest "/etc/dhcp/" (jinja "{{ item.filename }}"))
        (mode "0644"))
      (vars 
        (dhcpd__protocol (jinja "{{ item.protocol }}")))
      (loop (list
          
          (filename "dhcpd.conf")
          (protocol "DHCPv4")
          
          (filename "dhcpd6.conf")
          (protocol "DHCPv6")))
      (notify (list
          "Restart isc-dhcp-server")))
    (task "Configure ISC DHCP Server defaults"
      (ansible.builtin.template 
        (src "etc/default/isc-dhcp-server.j2")
        (dest "/etc/default/isc-dhcp-server")
        (mode "0644"))
      (notify (list
          "Restart isc-dhcp-server")))
    (task "Make sure that Ansible local facts directory exists"
      (ansible.builtin.file 
        (path "/etc/ansible/facts.d")
        (state "directory")
        (mode "0755")))
    (task "Save local facts"
      (ansible.builtin.template 
        (src "etc/ansible/facts.d/dhcpd.fact.j2")
        (dest "/etc/ansible/facts.d/dhcpd.fact")
        (mode "0755"))
      (notify (list
          "Refresh host facts"))
      (tags (list
          "meta::facts")))
    (task "Update Ansible facts if they were modified"
      (ansible.builtin.meta "flush_handlers"))))
