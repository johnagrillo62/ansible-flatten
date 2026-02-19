(playbook "debops/ansible/roles/mount/tasks/main.yml"
  (tasks
    (task "Install required packages"
      (ansible.builtin.package 
        (name (jinja "{{ (mount__base_packages + mount__packages) | flatten }}"))
        (state "present"))
      (register "mount__register_packages")
      (until "mount__register_packages is succeeded")
      (when "mount__enabled | bool"))
    (task "Ensure that the mount points exist"
      (ansible.builtin.file 
        (path (jinja "{{ item.path | d(item.dest | d(item.name)) }}"))
        (owner (jinja "{{ item.owner | d(omit) }}"))
        (group (jinja "{{ item.group | d(item.owner | d(omit)) }}"))
        (mode (jinja "{{ item.mode | d(\"0755\") }}"))
        (state "directory"))
      (loop (jinja "{{ (mount__devices
             + mount__group_devices
             + mount__host_devices)
            | flatten }}"))
      (when "(mount__enabled | bool and item.state | d('mounted') in ['mounted', 'present', 'unmounted'] and (item.device | d(item.src)) not in (ansible_mounts | map(attribute='device') | list))"))
    (task "Stop devices automounted by systemd if requested"
      (ansible.builtin.systemd 
        (name (jinja "{{ item.name | regex_replace(\"^/\", \"\") | regex_replace(\"/\", \"-\") + \".automount\" }}"))
        (state "stopped"))
      (loop (jinja "{{ (mount__devices
             + mount__group_devices
             + mount__host_devices)
            | flatten }}"))
      (when "(mount__enabled | bool and ansible_service_mgr == 'systemd' and item.state | d('mounted') in ['unmounted', 'absent'] and (((item.opts if (item.opts is string) else item.opts | join(',')) if item.opts | d() else 'defaults') is match(\".*x-systemd.automount.*\")))"))
    (task "Copy files to remote hosts"
      (ansible.builtin.copy 
        (dest (jinja "{{ item.dest | d(item.path | d(item.name)) }}"))
        (src (jinja "{{ item.src | d(omit) }}"))
        (content (jinja "{{ item.content | d(omit) }}"))
        (owner (jinja "{{ item.owner | d(omit) }}"))
        (group (jinja "{{ item.group | d(omit) }}"))
        (mode (jinja "{{ item.mode | d(omit) }}"))
        (selevel (jinja "{{ item.selevel | d(omit) }}"))
        (serole (jinja "{{ item.serole | d(omit) }}"))
        (setype (jinja "{{ item.setype | d(omit) }}"))
        (seuser (jinja "{{ item.seuser | d(omit) }}"))
        (follow (jinja "{{ item.follow | d(omit) }}"))
        (force (jinja "{{ item.force | d(omit) }}"))
        (backup (jinja "{{ item.backup | d(omit) }}"))
        (validate (jinja "{{ item.validate | d(omit) }}"))
        (remote_src (jinja "{{ item.remote_src | d(omit) }}"))
        (directory_mode (jinja "{{ item.directory_mode | d(omit) }}")))
      (loop (jinja "{{ q(\"flattened\", mount__files
                           + mount__group_files
                           + mount__host_files) }}"))
      (when "(mount__enabled | bool and (item.src | d() or item.content is defined) and (item.dest | d() or item.path | d() or item.name | d()) and (item.state | d('present') != 'absent'))"))
    (task "Manage device mounts"
      (ansible.posix.mount 
        (src (jinja "{{ item.src }}"))
        (path (jinja "{{ item.path | d(item.dest | d(item.name)) }}"))
        (fstype (jinja "{{ item.fstype | d(\"auto\") }}"))
        (opts (jinja "{{ ((item.opts if (item.opts is string) else (item.opts | join(\",\")))
                 if item.opts | d() else \"defaults\") }}"))
        (dump (jinja "{{ item.dump | d(omit) }}"))
        (passno (jinja "{{ item.passno | d(omit) }}"))
        (state (jinja "{{ item.state | d(\"mounted\") }}"))
        (fstab (jinja "{{ item.fstab | d(omit) }}")))
      (loop (jinja "{{ (mount__devices
             + mount__group_devices
             + mount__host_devices)
            | flatten }}"))
      (register "mount__register_devices")
      (when "(mount__enabled | bool and (item.name | d() or item.dest | d() or item.path | d()) and item.src)"))
    (task "Restart 'local-fs.target' systemd unit"
      (ansible.builtin.systemd 
        (name "local-fs.target")
        (state "restarted")
        (daemon_reload "True"))
      (loop (jinja "{{ mount__register_devices.results }}"))
      (when "(mount__enabled | bool and ansible_service_mgr == 'systemd' and item is changed and (((item.opts if (item.opts is string) else item.opts | join(',')) if item.opts | d() else 'defaults') is match(\".*x-systemd.automount.*\")))"))
    (task "Restart 'remote-fs.target' systemd unit"
      (ansible.builtin.systemd 
        (name "remote-fs.target")
        (state "restarted")
        (daemon_reload "True"))
      (loop (jinja "{{ mount__register_devices.results }}"))
      (when "(mount__enabled | bool and ansible_service_mgr == 'systemd' and item is changed and (((item.opts if (item.opts is string) else item.opts | join(',')) if item.opts | d() else 'defaults') is match(\".*x-systemd.automount.*\")))"))
    (task "Manage directories"
      (ansible.builtin.file 
        (path (jinja "{{ item.path | d(item.dest | d(item.name)) }}"))
        (owner (jinja "{{ item.owner | d(omit) }}"))
        (group (jinja "{{ item.group | d(item.owner | d(omit)) }}"))
        (mode (jinja "{{ item.mode | d(\"0755\") }}"))
        (recurse (jinja "{{ item.recurse | d(omit) }}"))
        (state (jinja "{{ item.state | d(\"directory\") }}")))
      (loop (jinja "{{ (mount__directories
             + mount__group_directories
             + mount__host_directories)
            | flatten }}"))
      (when "mount__enabled | bool and (item.path | d() or item.dest | d() or item.name | d()) and item.state | d('directory') in ['directory', 'absent']"))
    (task "Manage directory ACLs"
      (ansible.posix.acl 
        (path (jinja "{{ item.0.path | d(item.0.dest | d(item.0.name)) }}"))
        (default (jinja "{{ item.1.default | d(omit) }}"))
        (entity (jinja "{{ item.1.entity | d(omit) }}"))
        (etype (jinja "{{ item.1.etype | d(omit) }}"))
        (permissions (jinja "{{ item.1.permissions | d(omit) }}"))
        (follow (jinja "{{ item.1.follow | d(omit) }}"))
        (recursive (jinja "{{ item.1.recursive | d(omit) }}"))
        (state (jinja "{{ item.1.state | d(\"present\") }}")))
      (loop (jinja "{{ ((mount__directories
             + mount__group_directories
             + mount__host_directories)
             | flatten) | selectattr(\"acl\", \"defined\") | list
             | subelements(\"acl\") }}"))
      (loop_control 
        (label (jinja "{{ {\"name\": item.0.name, \"acl\": item.1} }}")))
      (when "mount__enabled | bool and (item.0.path | d() or item.0.dest | d() or item.0.name | d()) and item.0.state | d('directory') == 'directory' and item.0.acl | d()"))
    (task "Manage bind mounts"
      (ansible.posix.mount 
        (src (jinja "{{ item.src }}"))
        (path (jinja "{{ item.path | d(item.dest | d(item.name)) }}"))
        (fstype (jinja "{{ item.fstype | d(\"none\") }}"))
        (opts (jinja "{{ ((item.opts if (item.opts is string) else (item.opts | join(\",\"))) if item.opts | d() else \"bind\") }}"))
        (dump (jinja "{{ item.dump | d(omit) }}"))
        (passno (jinja "{{ item.passno | d(omit) }}"))
        (state (jinja "{{ item.state | d(\"mounted\") }}"))
        (fstab (jinja "{{ item.fstab | d(omit) }}")))
      (loop (jinja "{{ (mount__binds
             + mount__group_binds
             + mount__host_binds)
            | flatten }}"))
      (when "(mount__enabled | bool and (item.name | d() or item.dest | d() or item.path | d()) and item.src | d())"))
    (task "Make sure that Ansible local facts directory exists"
      (ansible.builtin.file 
        (path "/etc/ansible/facts.d")
        (state "directory")
        (owner "root")
        (group "root")
        (mode "0755")))
    (task "Save mount local facts"
      (ansible.builtin.template 
        (src "etc/ansible/facts.d/mount.fact.j2")
        (dest "/etc/ansible/facts.d/mount.fact")
        (owner "root")
        (group "root")
        (mode "0755"))
      (tags (list
          "meta::facts")))))
