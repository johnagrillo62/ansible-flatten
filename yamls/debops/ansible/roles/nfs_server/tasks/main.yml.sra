(playbook "debops/ansible/roles/nfs_server/tasks/main.yml"
  (tasks
    (task "Import DebOps global handlers"
      (ansible.builtin.import_role 
        (name "global_handlers")))
    (task "Install required packages"
      (ansible.builtin.package 
        (name (jinja "{{ q(\"flattened\", (nfs_server__base_packages
                              + nfs_server__packages)) }}"))
        (state "present"))
      (register "nfs_server__register_packages")
      (until "nfs_server__register_packages is succeeded"))
    (task "Configure NFS server"
      (ansible.builtin.template 
        (src (jinja "{{ item }}") ".j2")
        (dest "/" (jinja "{{ item }}"))
        (owner "root")
        (group "root")
        (mode "0644"))
      (with_items (list
          "etc/default/nfs-common"
          "etc/default/nfs-kernel-server"
          "etc/modprobe.d/nfs-server.conf"))
      (notify (list
          "Restart nfs-kernel-server service")))
    (task "Create /etc/exports.d/ directory"
      (ansible.builtin.file 
        (path "/etc/exports.d")
        (state "directory")
        (owner "root")
        (group "root")
        (mode "0755")))
    (task "Ensure exported directories exist"
      (ansible.builtin.file 
        (path (jinja "{{ item.path }}"))
        (state "directory")
        (owner (jinja "{{ item.owner | d(\"root\") }}"))
        (group (jinja "{{ item.group | d(\"root\") }}"))
        (mode (jinja "{{ item.mode | d(\"0755\") }}")))
      (loop (jinja "{{ q(\"flattened\", nfs_server__combined_exports) }}"))
      (when "item.path | d() and item.state | d('present') != 'absent' and item.acl | d()"))
    (task "Bind mount requested directories"
      (ansible.posix.mount 
        (name (jinja "{{ item.path }}"))
        (src (jinja "{{ item.bind.src | d(item.bind) }}"))
        (opts (jinja "{{ ([\"bind\"] + item.bind.options | d([])) | join(\",\") }}"))
        (fstype "none")
        (state "mounted"))
      (loop (jinja "{{ q(\"flattened\", nfs_server__combined_exports) }}"))
      (when "item.path | d() and item.state | d('present') != 'absent' and item.acl | d() and item.bind | d()"))
    (task "Configure NFS exports"
      (ansible.builtin.template 
        (src "etc/exports.d/ansible.exports.j2")
        (dest "/etc/exports.d/ansible.exports")
        (owner "root")
        (group "root")
        (mode "0644"))
      (notify (list
          "Reload NFS exports")))))
