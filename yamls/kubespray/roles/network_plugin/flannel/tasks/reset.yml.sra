(playbook "kubespray/roles/network_plugin/flannel/tasks/reset.yml"
  (tasks
    (task "Reset | check cni network device"
      (stat 
        (path "/sys/class/net/cni0")
        (get_attributes "false")
        (get_checksum "false")
        (get_mime "false"))
      (register "cni"))
    (task "Reset | remove the network device created by the flannel"
      (command "ip link del cni0")
      (when "cni.stat.exists"))
    (task "Reset | check flannel network device"
      (stat 
        (path "/sys/class/net/flannel.1")
        (get_attributes "false")
        (get_checksum "false")
        (get_mime "false"))
      (register "flannel"))
    (task "Reset | remove the network device created by the flannel"
      (command "ip link del flannel.1")
      (when "flannel.stat.exists"))))
