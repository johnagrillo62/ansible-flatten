(playbook "kubespray/roles/network_plugin/cilium/tasks/reset_iface.yml"
  (tasks
    (task "Reset | check if network device " (jinja "{{ iface }}") " is present"
      (stat 
        (path "/sys/class/net/" (jinja "{{ iface }}"))
        (get_attributes "false")
        (get_checksum "false")
        (get_mime "false"))
      (register "device_remains"))
    (task "Reset | remove network device " (jinja "{{ iface }}")
      (command "ip link del " (jinja "{{ iface }}"))
      (when "device_remains.stat.exists"))))
