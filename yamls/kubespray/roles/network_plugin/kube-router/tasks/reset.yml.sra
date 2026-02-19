(playbook "kubespray/roles/network_plugin/kube-router/tasks/reset.yml"
  (tasks
    (task "Reset | check kube-dummy-if network device"
      (stat 
        (path "/sys/class/net/kube-dummy-if")
        (get_attributes "false")
        (get_checksum "false")
        (get_mime "false"))
      (register "kube_dummy_if"))
    (task "Reset | remove the network device created by kube-router"
      (command "ip link del kube-dummy-if")
      (when "kube_dummy_if.stat.exists"))
    (task "Check kube-bridge exists"
      (stat 
        (path "/sys/class/net/kube-bridge")
        (get_attributes "false")
        (get_checksum "false")
        (get_mime "false"))
      (register "kube_bridge_if"))
    (task "Reset | donw the network bridge create by kube-router"
      (command "ip link set kube-bridge down")
      (when "kube_bridge_if.stat.exists"))
    (task "Reset | remove the network bridge create by kube-router"
      (command "ip link del kube-bridge")
      (when "kube_bridge_if.stat.exists"))))
