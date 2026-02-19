(playbook "debops/ansible/roles/unbound/tasks/main.yml"
  (tasks
    (task "Import custom Ansible plugins"
      (ansible.builtin.import_role 
        (name "ansible_plugins")))
    (task "Import DebOps global handlers"
      (ansible.builtin.import_role 
        (name "global_handlers")))
    (task "Create a fact that knows the Ansible connection type"
      (ansible.builtin.set_fact 
        (unbound__fact_ansible_connection (jinja "{{ ansible_connection }}"))))
    (task "Create Unbound configuration directory"
      (ansible.builtin.file 
        (path "/etc/unbound/unbound.conf.d")
        (state "directory")
        (owner "root")
        (group "root")
        (mode "0755")))
    (task "Remove Unbound server configuration"
      (ansible.builtin.file 
        (path "/etc/unbound/unbound.conf.d/ansible-server.conf")
        (state "absent"))
      (notify (list
          "Check unbound configuration and reload"))
      (when "not unbound__combined_server | d()"))
    (task "Remove Unbound remote control configuration"
      (ansible.builtin.file 
        (path "/etc/unbound/unbound.conf.d/ansible-remote-control.conf")
        (state "absent"))
      (notify (list
          "Check unbound configuration and reload"))
      (when "not unbound__combined_remote_control | d()"))
    (task "Generate Unbound server configuration"
      (ansible.builtin.template 
        (src "etc/unbound/unbound.conf.d/ansible-server.conf.j2")
        (dest "/etc/unbound/unbound.conf.d/ansible-server.conf")
        (owner "root")
        (group "root")
        (mode "0644"))
      (notify (list
          "Check unbound configuration and reload"))
      (when "unbound__combined_server | d()"))
    (task "Generate Unbound remote control configuration"
      (ansible.builtin.template 
        (src "etc/unbound/unbound.conf.d/ansible-remote-control.conf.j2")
        (dest "/etc/unbound/unbound.conf.d/ansible-remote-control.conf")
        (owner "root")
        (group "root")
        (mode "0644"))
      (notify (list
          "Check unbound configuration and reload"))
      (when "unbound__combined_remote_control | d()"))
    (task "Remove DNS zones if requested"
      (ansible.builtin.file 
        (path "/etc/unbound/unbound.conf.d/zone_" (jinja "{{ item.name }}") ".conf")
        (state "absent"))
      (loop (jinja "{{ q(\"flattened\", unbound__parsed_zones) }}"))
      (notify (list
          "Check unbound configuration and reload"))
      (when "item.name | d() and item.state | d('present') == 'absent'"))
    (task "Configure DNS zones"
      (ansible.builtin.template 
        (src "etc/unbound/unbound.conf.d/zone.conf.j2")
        (dest "/etc/unbound/unbound.conf.d/zone_" (jinja "{{ item.name }}") ".conf")
        (owner "root")
        (group "root")
        (mode "0644"))
      (loop (jinja "{{ q(\"flattened\", unbound__parsed_zones) }}"))
      (notify (list
          "Check unbound configuration and reload"))
      (when "item.name | d() and item.state | d('present') != 'absent'"))
    (task "Install unbound APT packages"
      (ansible.builtin.package 
        (name (jinja "{{ q(\"flattened\", (unbound__base_packages
                              + unbound__packages)) }}"))
        (state "present"))
      (register "unbound__register_packages")
      (until "unbound__register_packages is succeeded"))
    (task "Make sure that Ansible local facts directory exists"
      (ansible.builtin.file 
        (path "/etc/ansible/facts.d")
        (state "directory")
        (owner "root")
        (group "root")
        (mode "0755")))
    (task "Save Unbound local facts"
      (ansible.builtin.template 
        (src "etc/ansible/facts.d/unbound.fact.j2")
        (dest "/etc/ansible/facts.d/unbound.fact")
        (owner "root")
        (group "root")
        (mode "0755"))
      (notify (list
          "Refresh host facts"))
      (tags (list
          "meta::facts")))
    (task "Update Ansible facts if they were modified"
      (ansible.builtin.meta "flush_handlers"))))
