(playbook "kubespray/roles/network_plugin/ovn4nfv/tasks/main.yml"
  (tasks
    (task "Ovn4nfv | Label control-plane node"
      (command (jinja "{{ kubectl }}") " label --overwrite node " (jinja "{{ groups['kube_control_plane'] | first }}") " ovn4nfv-k8s-plugin=ovn-control-plane")
      (when (list
          "inventory_hostname == groups['kube_control_plane'][0]")))
    (task "Ovn4nfv | Create ovn4nfv-k8s manifests"
      (template 
        (src (jinja "{{ item.file }}") ".j2")
        (dest (jinja "{{ kube_config_dir }}") "/" (jinja "{{ item.file }}"))
        (mode "0644"))
      (with_items (list
          
          (name "ovn-daemonset")
          (file "ovn-daemonset.yml")
          
          (name "ovn4nfv-k8s-plugin")
          (file "ovn4nfv-k8s-plugin.yml")))
      (register "ovn4nfv_node_manifests"))))
