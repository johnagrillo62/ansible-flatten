(playbook "kubespray/roles/network_plugin/multus/tasks/main.yml"
  (tasks
    (task "Multus | Copy manifest files"
      (copy 
        (src (jinja "{{ item.file }}"))
        (dest (jinja "{{ kube_config_dir }}"))
        (mode "0644"))
      (with_items (list
          
          (name "multus-crd")
          (file "multus-crd.yml")
          (type "customresourcedefinition")
          
          (name "multus-serviceaccount")
          (file "multus-serviceaccount.yml")
          (type "serviceaccount")
          
          (name "multus-clusterrole")
          (file "multus-clusterrole.yml")
          (type "clusterrole")
          
          (name "multus-clusterrolebinding")
          (file "multus-clusterrolebinding.yml")
          (type "clusterrolebinding")))
      (register "multus_manifest_1")
      (when "inventory_hostname == groups['kube_control_plane'][0]"))
    (task "Multus | Check container engine type"
      (set_fact 
        (container_manager_types (jinja "{{ ansible_play_hosts_all | map('extract', hostvars, ['container_manager']) | list | unique }}"))))
    (task "Multus | Copy manifest templates"
      (template 
        (src "multus-daemonset.yml.j2")
        (dest (jinja "{{ kube_config_dir }}") "/" (jinja "{{ item.file }}"))
        (mode "0644"))
      (with_items (list
          
          (name "multus-daemonset-containerd")
          (file "multus-daemonset-containerd.yml")
          (type "daemonset")
          (engine "containerd")
          
          (name "multus-daemonset-docker")
          (file "multus-daemonset-docker.yml")
          (type "daemonset")
          (engine "docker")
          
          (name "multus-daemonset-crio")
          (file "multus-daemonset-crio.yml")
          (type "daemonset")
          (engine "crio")))
      (register "multus_manifest_2")
      (vars 
        (host_query "*|[?container_manager=='" (jinja "{{ container_manager }}") "']|[0].inventory_hostname")
        (vars_from_node (jinja "{{ hostvars | json_query(host_query) }}")))
      (delegate_to (jinja "{{ groups['kube_control_plane'][0] }}"))
      (when (list
          "item.engine in container_manager_types"
          "hostvars[inventory_hostname].container_manager == item.engine"
          "inventory_hostname == vars_from_node")))
    (task "Multus | Start resources"
      (kube 
        (name (jinja "{{ item.item.name }}"))
        (namespace "kube-system")
        (kubectl (jinja "{{ bin_dir }}") "/kubectl")
        (resource (jinja "{{ item.item.type }}"))
        (filename (jinja "{{ kube_config_dir }}") "/" (jinja "{{ item.item.file }}"))
        (state "latest"))
      (delegate_to (jinja "{{ groups['kube_control_plane'][0] }}"))
      (run_once "true")
      (with_items (jinja "{{ (multus_manifest_1.results | default([])) + (multus_nodes_list | map('extract', hostvars, 'multus_manifest_2') | map('default', []) | list | json_query('[].results')) }}"))
      (loop_control 
        (label (jinja "{{ item.item.name if item != None else 'skipped' }}")))
      (vars 
        (multus_nodes_list (jinja "{{ groups['k8s_cluster'] if ansible_play_batch | length == ansible_play_hosts_all | length else ansible_play_batch }}")))
      (when (list
          "not item is skipped")))))
