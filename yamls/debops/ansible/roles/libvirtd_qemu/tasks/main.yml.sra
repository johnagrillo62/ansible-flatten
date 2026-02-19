(playbook "debops/ansible/roles/libvirtd_qemu/tasks/main.yml"
  (tasks
    (task "Import DebOps global handlers"
      (ansible.builtin.import_role 
        (name "global_handlers")))
    (task "Check if host supports hardware virtualization"
      (ansible.builtin.shell "set -o nounset -o pipefail -o errexit && egrep --color=auto 'vmx|svm|0xc0f' /proc/cpuinfo || true")
      (args 
        (executable "bash"))
      (register "libvirtd_qemu__register_hw_virt")
      (check_mode "False")
      (changed_when "False"))
    (task "Install libvirt if not already installed"
      (ansible.builtin.package 
        (name (jinja "{{ q(\"flattened\", ((libvirtd_qemu__base_packages_map[ansible_distribution_release]
                               if (ansible_distribution_release in libvirtd_qemu__base_packages_map.keys())
                               else libvirtd_qemu__base_packages)
                              + (libvirtd_qemu__kvm_packages if libvirtd_qemu__kvm_support | bool else [])
                              + libvirtd_qemu__packages)) }}"))
        (state "present"))
      (register "libvirtd_qemu__register_packages")
      (until "libvirtd_qemu__register_packages is succeeded")
      (when "(ansible_local is undefined or (ansible_local | d() and ansible_local.libvirtd is undefined or (ansible_local | d() and ansible_local.libvirtd | d() and (ansible_local.libvirtd.installed is undefined or not ansible_local.libvirtd.installed | bool))))"))
    (task "Make sure required directories exist"
      (ansible.builtin.file 
        (path "/etc/libvirt")
        (state "directory")
        (owner "root")
        (group "root")
        (mode "0755")))
    (task "Divert managed configuration files"
      (debops.debops.dpkg_divert 
        (path "/etc/libvirt/qemu.conf")))
    (task "Generate QEMU private configuration files"
      (ansible.builtin.template 
        (src (jinja "{{ item }}") ".j2")
        (dest "/" (jinja "{{ item }}"))
        (owner "root")
        (group "root")
        (mode "0600"))
      (with_items (list
          "etc/libvirt/qemu.conf"))
      (notify (list
          "Restart libvirtd"
          "Restart libvirt-bin")))))
