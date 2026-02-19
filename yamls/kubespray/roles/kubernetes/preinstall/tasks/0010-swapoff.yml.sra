(playbook "kubespray/roles/kubernetes/preinstall/tasks/0010-swapoff.yml"
  (tasks
    (task "Check if /etc/fstab exists"
      (stat 
        (path "/etc/fstab")
        (get_attributes "false")
        (get_checksum "false")
        (get_mime "false"))
      (register "fstab_file"))
    (task "Remove swapfile from /etc/fstab"
      (ansible.posix.mount 
        (name (jinja "{{ item }}"))
        (fstype "swap")
        (state "absent"))
      (loop (list
          "swap"
          "none"))
      (when "fstab_file.stat.exists"))
    (task "Mask swap.target (persist swapoff)"
      (ansible.builtin.systemd_service 
        (name "swap.target")
        (masked "true")))
    (task "Disable swap"
      (command "/sbin/swapoff -a"))))
