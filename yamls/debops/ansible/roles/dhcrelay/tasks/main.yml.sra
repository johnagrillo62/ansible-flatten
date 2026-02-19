(playbook "debops/ansible/roles/dhcrelay/tasks/main.yml"
  (tasks
    (task "Import custom Ansible plugins"
      (ansible.builtin.import_role 
        (name "ansible_plugins")))
    (task "Import DebOps global handlers"
      (ansible.builtin.import_role 
        (name "global_handlers")))
    (task "Install ISC DHCP relay packages"
      (ansible.builtin.package 
        (name (jinja "{{ (dhcrelay__base_packages + dhcrelay__packages) | flatten }}"))
        (state "present"))
      (register "dhcrelay__register_packages")
      (until "dhcrelay__register_packages is succeeded"))
    (task "Divert ISC DHCP relay defaults"
      (debops.debops.dpkg_divert 
        (path "/etc/default/isc-dhcp-relay")))
    (task "Configure ISC DHCP relay defaults"
      (ansible.builtin.template 
        (src "etc/default/isc-dhcp-relay.j2")
        (dest "/etc/default/isc-dhcp-relay")
        (mode "0644"))
      (notify (list
          "Restart isc-dhcp-relay")))
    (task "Make sure that Ansible local facts directory exists"
      (ansible.builtin.file 
        (path "/etc/ansible/facts.d")
        (state "directory")
        (mode "0755")))
    (task "Save local facts"
      (ansible.builtin.template 
        (src "etc/ansible/facts.d/dhcrelay.fact.j2")
        (dest "/etc/ansible/facts.d/dhcrelay.fact")
        (mode "0755"))
      (notify (list
          "Refresh host facts"))
      (tags (list
          "meta::facts")))
    (task "Update Ansible facts if they were modified"
      (ansible.builtin.meta "flush_handlers"))))
