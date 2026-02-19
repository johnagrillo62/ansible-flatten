(playbook "kubespray/roles/kubernetes/preinstall/tasks/0080-system-configurations.yml"
  (tasks
    (task "Confirm selinux deployed"
      (stat 
        (path "/etc/selinux/config")
        (get_attributes "false")
        (get_checksum "false")
        (get_mime "false"))
      (when (list
          "ansible_os_family == \"RedHat\""
          "'Amazon' not in ansible_distribution"))
      (register "slc"))
    (task "Set selinux policy"
      (ansible.posix.selinux 
        (policy "targeted")
        (state (jinja "{{ preinstall_selinux_state }}")))
      (when (list
          "ansible_os_family == \"RedHat\""
          "'Amazon' not in ansible_distribution"
          "slc.stat.exists"))
      (tags (list
          "bootstrap_os")))
    (task "Disable IPv6 DNS lookup"
      (lineinfile 
        (dest "/etc/gai.conf")
        (line "precedence ::ffff:0:0/96  100")
        (state "present")
        (create "true")
        (backup (jinja "{{ leave_etc_backup_files }}"))
        (mode "0644"))
      (when (list
          "disable_ipv6_dns"
          "not ansible_os_family in [\"Flatcar\", \"Flatcar Container Linux by Kinvolk\"]"))
      (tags (list
          "bootstrap_os")))
    (task "Clean previously used sysctl file locations"
      (file 
        (path "/etc/sysctl.d/" (jinja "{{ item }}"))
        (state "absent"))
      (with_items (list
          "ipv4-ip_forward.conf"
          "bridge-nf-call.conf")))
    (task "Stat sysctl file configuration"
      (stat 
        (path (jinja "{{ sysctl_file_path }}"))
        (get_attributes "false")
        (get_checksum "false")
        (get_mime "false"))
      (register "sysctl_file_stat")
      (tags (list
          "bootstrap_os")))
    (task "Change sysctl file path to link source if linked"
      (set_fact 
        (sysctl_file_path (jinja "{{ sysctl_file_stat.stat.lnk_source }}")))
      (when (list
          "sysctl_file_stat.stat.islnk is defined"
          "sysctl_file_stat.stat.islnk"))
      (tags (list
          "bootstrap_os")))
    (task "Make sure sysctl file path folder exists"
      (file 
        (name (jinja "{{ sysctl_file_path | dirname }}"))
        (state "directory")
        (mode "0755")))
    (task "Enable ip forwarding"
      (ansible.posix.sysctl 
        (sysctl_file (jinja "{{ sysctl_file_path }}"))
        (name "net.ipv4.ip_forward")
        (value "1")
        (state "present")
        (reload "true")
        (ignoreerrors (jinja "{{ sysctl_ignore_unknown_keys }}")))
      (when "ipv4_stack | bool"))
    (task "Enable ipv6 forwarding"
      (ansible.posix.sysctl 
        (sysctl_file (jinja "{{ sysctl_file_path }}"))
        (name "net.ipv6.conf.all.forwarding")
        (value "1")
        (state "present")
        (reload "true")
        (ignoreerrors (jinja "{{ sysctl_ignore_unknown_keys }}")))
      (when "ipv6_stack | bool"))
    (task "Check if we need to set fs.may_detach_mounts"
      (stat 
        (path "/proc/sys/fs/may_detach_mounts")
        (get_attributes "false")
        (get_checksum "false")
        (get_mime "false"))
      (register "fs_may_detach_mounts")
      (ignore_errors "true"))
    (task "Set fs.may_detach_mounts if needed"
      (ansible.posix.sysctl 
        (sysctl_file (jinja "{{ sysctl_file_path }}"))
        (name "fs.may_detach_mounts")
        (value "1")
        (state "present")
        (reload "true")
        (ignoreerrors (jinja "{{ sysctl_ignore_unknown_keys }}")))
      (when "fs_may_detach_mounts.stat.exists | d(false)"))
    (task "Ensure kubelet expected parameters are set"
      (ansible.posix.sysctl 
        (sysctl_file (jinja "{{ sysctl_file_path }}"))
        (name (jinja "{{ item.name }}"))
        (value (jinja "{{ item.value }}"))
        (state "present")
        (reload "true")
        (ignoreerrors (jinja "{{ sysctl_ignore_unknown_keys }}")))
      (with_items (list
          
          (name "kernel.keys.root_maxbytes")
          (value "25000000")
          
          (name "kernel.keys.root_maxkeys")
          (value "1000000")
          
          (name "kernel.panic")
          (value "10")
          
          (name "kernel.panic_on_oops")
          (value "1")
          
          (name "vm.overcommit_memory")
          (value "1")
          
          (name "vm.panic_on_oom")
          (value "0")))
      (when "kubelet_protect_kernel_defaults | bool"))
    (task "Check dummy module"
      (community.general.modprobe 
        (name "dummy")
        (state "present")
        (params "numdummies=0"))
      (when "enable_nodelocaldns"))
    (task "Set additional sysctl variables"
      (ansible.posix.sysctl 
        (sysctl_file (jinja "{{ sysctl_file_path }}"))
        (name (jinja "{{ item.name }}"))
        (value (jinja "{{ item.value }}"))
        (state "present")
        (reload "true")
        (ignoreerrors (jinja "{{ sysctl_ignore_unknown_keys }}")))
      (with_items (jinja "{{ additional_sysctl }}")))
    (task "Disable fapolicyd service"
      (systemd_service 
        (name "fapolicyd")
        (state "stopped")
        (enabled "false"))
      (failed_when "false")
      (when "disable_fapolicyd"))))
