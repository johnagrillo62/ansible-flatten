(playbook "debops/ansible/roles/fuse/tasks/main.yml"
  (tasks
    (task "Import custom Ansible plugins"
      (ansible.builtin.import_role 
        (name "ansible_plugins")))
    (task "Install required packages"
      (ansible.builtin.package 
        (name (jinja "{{ q(\"flattened\", fuse_base_packages) }}"))
        (state "present"))
      (register "fuse__register_packages")
      (until "fuse__register_packages is succeeded"))
    (task "Divert original /etc/fuse.conf"
      (debops.debops.dpkg_divert 
        (path "/etc/fuse.conf")))
    (task "Setup udev rule for fuse to change file permissions"
      (ansible.builtin.template 
        (src "etc/fuse.conf.j2")
        (dest "/etc/fuse.conf")
        (mode "0644")))
    (task "Ensure fuse system group is present"
      (ansible.builtin.group 
        (name (jinja "{{ fuse_group }}"))
        (state "present")
        (system "True")))
    (task "Add fuse_users to fuse_group"
      (ansible.builtin.user 
        (name (jinja "{{ item }}"))
        (groups (jinja "{{ fuse_group }}"))
        (append "True"))
      (loop (jinja "{{ [fuse_users, fuse_users_host_group, fuse_users_host] | flatten }}")))
    (task "Setup udev rule for fuse to change file permissions"
      (ansible.builtin.template 
        (src "etc/udev/rules.d/fuse.rules.j2")
        (dest "/etc/udev/rules.d/99-fuse.rules")
        (mode "0644"))
      (when "fuse_restrict_access | bool"))
    (task "Ensure FUSE permissions are applied immediately"
      (ansible.builtin.file 
        (path "/dev/fuse")
        (owner "root")
        (group (jinja "{{ fuse_group }}"))
        (mode (jinja "{{ fuse_permissions }}")))
      (when "fuse_restrict_access | bool"))
    (task "Remove udev rule for fuse"
      (ansible.builtin.file 
        (path "/etc/udev/rules.d/99-fuse.rules")
        (state "absent"))
      (when "not (fuse_restrict_access | bool)"))))
