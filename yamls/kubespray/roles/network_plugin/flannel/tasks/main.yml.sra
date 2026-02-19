(playbook "kubespray/roles/network_plugin/flannel/tasks/main.yml"
  (tasks
    (task "Flannel | Stop if kernel version is too low for Flannel Wireguard encryption"
      (assert 
        (that "ansible_kernel.split('-')[0] is version('5.6.0', '>=')"))
      (when (list
          "kube_network_plugin == 'flannel'"
          "flannel_backend_type == 'wireguard'"
          "not ignore_assert_errors")))
    (task "Flannel | Create Flannel manifests"
      (template 
        (src (jinja "{{ item.file }}") ".j2")
        (dest (jinja "{{ kube_config_dir }}") "/" (jinja "{{ item.file }}"))
        (mode "0644"))
      (with_items (list
          
          (name "flannel")
          (file "cni-flannel-rbac.yml")
          (type "sa")
          
          (name "kube-flannel")
          (file "cni-flannel.yml")
          (type "ds")))
      (register "flannel_node_manifests")
      (when (list
          "inventory_hostname == groups['kube_control_plane'][0]")))
    (task "Flannel | Start Resources"
      (kube 
        (name (jinja "{{ item.item.name }}"))
        (namespace "kube-system")
        (kubectl (jinja "{{ bin_dir }}") "/kubectl")
        (resource (jinja "{{ item.item.type }}"))
        (filename (jinja "{{ kube_config_dir }}") "/" (jinja "{{ item.item.file }}"))
        (state "latest"))
      (with_items (jinja "{{ flannel_node_manifests.results }}"))
      (when "inventory_hostname == groups['kube_control_plane'][0] and not item is skipped"))
    (task "Flannel | Wait for flannel subnet.env file presence"
      (wait_for 
        (path "/run/flannel/subnet.env")
        (delay "5")
        (timeout "600")))))
