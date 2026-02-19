(playbook "kubespray/roles/network_plugin/kube-ovn/tasks/main.yml"
  (tasks
    (task "Kube-OVN | Label ovn-db node"
      (command (jinja "{{ kubectl }}") " label --overwrite node " (jinja "{{ item }}") " kube-ovn/role=master")
      (loop (jinja "{{ kube_ovn_central_hosts }}"))
      (when (list
          "inventory_hostname == groups['kube_control_plane'][0]")))
    (task "Kube-OVN | Create Kube-OVN manifests"
      (template 
        (src (jinja "{{ item.file }}") ".j2")
        (dest (jinja "{{ kube_config_dir }}") "/" (jinja "{{ item.file }}"))
        (mode "0644"))
      (with_items (list
          
          (name "kube-ovn-crd")
          (file "cni-kube-ovn-crd.yml")
          
          (name "ovn")
          (file "cni-ovn.yml")
          
          (name "kube-ovn")
          (file "cni-kube-ovn.yml")))
      (register "kube_ovn_node_manifests"))
    (task "Kube-OVN | Start Resources"
      (kube 
        (name (jinja "{{ item.item.name }}"))
        (kubectl (jinja "{{ bin_dir }}") "/kubectl")
        (filename (jinja "{{ kube_config_dir }}") "/" (jinja "{{ item.item.file }}"))
        (state "latest"))
      (with_items (jinja "{{ kube_ovn_node_manifests.results }}"))
      (when "inventory_hostname == groups['kube_control_plane'][0] and not item is skipped"))))
