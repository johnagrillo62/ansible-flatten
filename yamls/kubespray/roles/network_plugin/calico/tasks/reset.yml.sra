(playbook "kubespray/roles/network_plugin/calico/tasks/reset.yml"
  (tasks
    (task "Reset | check vxlan.calico network device"
      (stat 
        (path "/sys/class/net/vxlan.calico")
        (get_attributes "false")
        (get_checksum "false")
        (get_mime "false"))
      (register "vxlan"))
    (task "Reset | remove the network vxlan.calico device created by calico"
      (command "ip link del vxlan.calico")
      (when "vxlan.stat.exists"))
    (task "Reset | check dummy0 network device"
      (stat 
        (path "/sys/class/net/dummy0")
        (get_attributes "false")
        (get_checksum "false")
        (get_mime "false"))
      (register "dummy0"))
    (task "Reset | remove the network device created by calico"
      (command "ip link del dummy0")
      (when "dummy0.stat.exists"))
    (task "Reset | get and remove remaining routes set by bird"
      (shell "set -o pipefail && ip route show proto bird | xargs -i bash -c \"ip route del {} proto bird \"")
      (args 
        (executable "/bin/bash"))
      (changed_when "false"))))
