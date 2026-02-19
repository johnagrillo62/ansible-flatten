(playbook "debops/ansible/roles/nfs/tasks/main.yml"
  (tasks
    (task "Install required packages"
      (ansible.builtin.package 
        (name (jinja "{{ q(\"flattened\", (nfs__base_packages
                              + nfs__packages)) }}"))
        (state "present"))
      (register "nfs__register_packages")
      (until "nfs__register_packages is succeeded"))
    (task "Configure NFS client"
      (ansible.builtin.template 
        (src (jinja "{{ item }}") ".j2")
        (dest "/" (jinja "{{ item }}"))
        (owner "root")
        (group "root")
        (mode "0644"))
      (with_items (list
          "etc/default/nfs-common"))
      (register "nfs__register_config"))
    (task "Ensure that the NFS mount points exist"
      (ansible.builtin.file 
        (path (jinja "{{ item.path }}"))
        (owner (jinja "{{ item.owner | d(\"root\") }}"))
        (group (jinja "{{ item.group | d(\"root\") }}"))
        (mode (jinja "{{ item.mode | d(\"0755\") }}"))
        (state "directory"))
      (loop (jinja "{{ q(\"flattened\", nfs__shares
                           + nfs__group_shares
                           + nfs__host_shares) }}"))
      (when "item.path | d() and item.src | d() and item.state | d('mounted') == 'present'"))
    (task "Manage NFS mount points"
      (ansible.posix.mount 
        (name (jinja "{{ item.path }}"))
        (src (jinja "{{ item.src }}"))
        (fstype (jinja "{{ item.fstype | d(nfs__default_mount_type) }}"))
        (opts (jinja "{{ lookup(\"template\", \"lookup/mount_options.j2\") | from_yaml }}"))
        (state (jinja "{{ item.state | d(\"mounted\") }}"))
        (passno (jinja "{{ item.passno | d(omit) }}"))
        (dump (jinja "{{ item.dump | d(omit) }}"))
        (fstab (jinja "{{ item.fstab | d(omit) }}")))
      (loop (jinja "{{ q(\"flattened\", nfs__shares
                           + nfs__group_shares
                           + nfs__host_shares) }}"))
      (register "nfs__register_devices")
      (when "item.path | d() and item.src | d()"))
    (task "Restart 'remote-fs.target' systemd unit"
      (ansible.builtin.systemd 
        (name "remote-fs.target")
        (state "restarted")
        (daemon_reload "True"))
      (loop (jinja "{{ nfs__register_devices.results }}"))
      (when "(ansible_service_mgr == 'systemd' and item is changed and (lookup(\"template\", \"lookup/mount_options.j2\") is match(\".*x-systemd.automount.*\")))"))))
