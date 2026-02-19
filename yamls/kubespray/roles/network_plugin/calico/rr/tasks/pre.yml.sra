(playbook "kubespray/roles/network_plugin/calico/rr/tasks/pre.yml"
  (tasks
    (task "Calico-rr | Disable calico-rr service if it exists"
      (service 
        (name "calico-rr")
        (state "stopped")
        (enabled "false"))
      (failed_when "false"))
    (task "Calico-rr | Delete obsolete files"
      (file 
        (path (jinja "{{ item }}"))
        (state "absent"))
      (with_items (list
          "/etc/calico/calico-rr.env"
          "/etc/systemd/system/calico-rr.service")))))
