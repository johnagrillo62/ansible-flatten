(playbook "debops/ansible/roles/samba/tasks/main.yml"
  (tasks
    (task "Import DebOps global handlers"
      (ansible.builtin.import_role 
        (name "global_handlers")))
    (task "Install Samba packages"
      (ansible.builtin.package 
        (name (jinja "{{ q(\"flattened\", samba__base_packages) }}"))
        (state "present"))
      (register "samba__register_packages")
      (until "samba__register_packages is succeeded"))
    (task "Create root Samba directories"
      (ansible.builtin.file 
        (path (jinja "{{ item }}"))
        (state "directory")
        (owner "root")
        (group "root")
        (mode "0751"))
      (loop (jinja "{{ q(\"flattened\", samba__path
                           + samba__homes_path
                           + samba__shares_path) }}"))
      (when "('samba' in samba__base_packages)"))
    (task "Setup samba-homedir.sh script"
      (ansible.builtin.template 
        (src "usr/local/sbin/samba-homedir.sh.j2")
        (dest "/usr/local/sbin/samba-homedir.sh")
        (owner "root")
        (group "root")
        (mode "0755"))
      (when "('samba' in samba__base_packages)"))
    (task "Configure Samba"
      (ansible.builtin.template 
        (src "etc/samba/smb.conf.j2")
        (dest "/etc/samba/smb.conf")
        (owner "root")
        (group "root")
        (mode "0644"))
      (notify (list
          "Check samba config")))
    (task "Load kernel module specified by samba__kernel_modules"
      (community.general.modprobe 
        (name (jinja "{{ item }}"))
        (state "present"))
      (loop (jinja "{{ q(\"flattened\", samba__kernel_modules) }}"))
      (when "(('samba' in samba__base_packages) and (samba__kernel_modules_load | bool))"))
    (task "Ensure kernel modules are loaded on system boot"
      (ansible.builtin.template 
        (src "etc/modules-load.d/ansible-samba.conf.j2")
        (dest "/etc/modules-load.d/ansible-samba.conf")
        (owner "root")
        (group "root")
        (mode "0644"))
      (when "(('samba' in samba__base_packages) and (samba__kernel_modules_load | bool))"))
    (task "Remove legacy entries from /etc/modules"
      (ansible.builtin.lineinfile 
        (dest "/etc/modules")
        (regexp "^nf_conntrack_netbios_ns")
        (state "absent")))))
