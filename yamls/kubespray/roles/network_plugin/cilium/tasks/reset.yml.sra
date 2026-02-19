(playbook "kubespray/roles/network_plugin/cilium/tasks/reset.yml"
  (tasks
    (task "Reset | check and remove devices if still present"
      (include_tasks "reset_iface.yml")
      (vars 
        (iface (jinja "{{ item }}")))
      (loop (list
          "cilium_host"
          "cilium_net"
          "cilium_vxlan")))))
