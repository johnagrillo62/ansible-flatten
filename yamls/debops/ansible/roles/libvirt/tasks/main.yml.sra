(playbook "debops/ansible/roles/libvirt/tasks/main.yml"
  (tasks
    (task "Import DebOps secret role"
      (ansible.builtin.import_role 
        (name "secret")))
    (task "Install libvirt support"
      (ansible.builtin.package 
        (name (jinja "{{ q(\"flattened\", (libvirt__base_packages
                              + (libvirt__packages_map[ansible_distribution_release]
                                 | d(libvirt__packages)))) }}"))
        (state "present"))
      (register "libvirt__register_packages")
      (until "libvirt__register_packages is succeeded"))
    (task "Create configuration directory"
      (ansible.builtin.file 
        (path "~/.config/libvirt")
        (state "directory")
        (mode "0755"))
      (become "False"))
    (task "Generate libvirt.conf configuration"
      (ansible.builtin.template 
        (src "home/config/libvirt/libvirt.conf.j2")
        (dest "~/.config/libvirt/libvirt.conf")
        (mode "0644"))
      (become "False"))
    (task "Get list of groups admin account belongs to"
      (ansible.builtin.command "groups")
      (register "libvirt__register_groups")
      (changed_when "False")
      (check_mode "False")
      (become "False")
      (tags (list
          "role::libvirt:networks"
          "role::libvirt:pools")))
    (task "Manage libvirt networks"
      (ansible.builtin.include_tasks "manage_networks.yml")
      (when "libvirt__group_map[ansible_distribution] in libvirt__register_groups.stdout.split(\" \")")
      (tags (list
          "role::libvirt:networks")))
    (task "Manage libvirt pools"
      (ansible.builtin.include_tasks "manage_pools.yml")
      (when "libvirt__group_map[ansible_distribution] in libvirt__register_groups.stdout.split(\" \")")
      (tags (list
          "role::libvirt:pools")))))
