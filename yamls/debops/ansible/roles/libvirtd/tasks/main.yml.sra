(playbook "debops/ansible/roles/libvirtd/tasks/main.yml"
  (tasks
    (task "Import DebOps global handlers"
      (ansible.builtin.import_role 
        (name "global_handlers")))
    (task "Check if host supports hardware virtualization"
      (ansible.builtin.shell "set -o nounset -o pipefail -o errexit && egrep 'vmx|svm|0xc0f' /proc/cpuinfo || true")
      (args 
        (executable "bash"))
      (register "libvirtd__register_hw_virt")
      (check_mode "False")
      (changed_when "False"))
    (task "Install libvirtd support"
      (ansible.builtin.package 
        (name (jinja "{{ q(\"flattened\", (libvirtd__network_packages
                              + libvirtd__misc_packages
                              + libvirtd__packages
                              + (libvirtd__base_packages_map[ansible_distribution_release]
                                 if (ansible_distribution_release in libvirtd__base_packages_map.keys())
                                 else libvirtd__base_packages)
                              + (libvirtd__kvm_packages
                                 if libvirtd__kvm_support | bool
                                 else []))) }}"))
        (state "present")
        (install_recommends "False"))
      (register "libvirtd__register_packages")
      (until "libvirtd__register_packages is succeeded"))
    (task "Make sure that Ansible local facts directory exists"
      (ansible.builtin.file 
        (path "/etc/ansible/facts.d")
        (state "directory")
        (owner "root")
        (group "root")
        (mode "0755")))
    (task "Save libvirtd local facts"
      (ansible.builtin.template 
        (src "etc/ansible/facts.d/libvirtd.fact.j2")
        (dest "/etc/ansible/facts.d/libvirtd.fact")
        (owner "root")
        (group "root")
        (mode "0755"))
      (notify (list
          "Refresh host facts"))
      (tags (list
          "meta::facts")))
    (task "Update Ansible facts if they were modified"
      (ansible.builtin.meta "flush_handlers"))
    (task "Divert managed configuration files"
      (debops.debops.dpkg_divert 
        (path (jinja "{{ item }}")))
      (loop (list
          "/etc/libvirt/libvirt.conf"
          "/etc/libvirt/libvirtd.conf")))
    (task "Generate libvirt configuration files"
      (ansible.builtin.template 
        (src (jinja "{{ item }}") ".j2")
        (dest "/" (jinja "{{ item }}"))
        (owner "root")
        (group "root")
        (mode "0644"))
      (with_items (list
          "etc/libvirt/libvirt.conf")))
    (task "Generate libvirtd configuration files"
      (ansible.builtin.template 
        (src (jinja "{{ item }}") ".j2")
        (dest "/" (jinja "{{ item }}"))
        (owner "root")
        (group "root")
        (mode "0644"))
      (with_items (list
          "etc/libvirt/libvirtd.conf"))
      (notify (list
          "Restart libvirtd"
          "Restart libvirt-bin")))
    (task "Add administrators to libvirtd access group"
      (ansible.builtin.user 
        (name (jinja "{{ item }}"))
        (groups (jinja "{{ libvirtd__unix_sock_group }}"))
        (append "True"))
      (with_items (jinja "{{ libvirtd__admins }}"))
      (when "libvirtd__admins | d()"))
    (task "Install ferm post hook"
      (ansible.builtin.template 
        (src "etc/ferm/hooks/post.d/reload-libvirtd.j2")
        (dest "/etc/ferm/hooks/post.d/reload-libvirtd")
        (owner "root")
        (group "root")
        (mode "0755"))
      (when "libvirtd__ferm_post_hook | bool"))
    (task "Configure Kernel Same-page Merging"
      (ansible.builtin.template 
        (src "etc/sysfs.d/ksm.conf.j2")
        (dest "/etc/sysfs.d/ksm.conf")
        (owner "root")
        (group "root")
        (mode "0644"))
      (notify (list
          "Restart sysfsutils")))
    (task "Check /sys filesystem mount options"
      (ansible.builtin.shell "set -o nounset -o pipefail -o errexit && findmnt -n -o FS-OPTIONS --target /sys | tr ',' '\\n'")
      (args 
        (executable "bash"))
      (register "libvirtd__register_sysfs")
      (changed_when "False")
      (check_mode "False"))))
