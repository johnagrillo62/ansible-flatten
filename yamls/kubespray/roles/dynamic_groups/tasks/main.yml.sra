(playbook "kubespray/roles/dynamic_groups/tasks/main.yml"
  (tasks
    (task "Match needed groups by their old names or definition"
      (group_by 
        (key (jinja "{{ item.key }}")))
      (vars 
        (group_mappings 
          (kube_control_plane (list
              "kube-master"))
          (kube_node (list
              "kube-node"))
          (calico_rr (list
              "calico-rr"))
          (no_floating (list
              "no-floating"))
          (k8s_cluster (list
              "kube_node"
              "kube_control_plane"
              "calico_rr"))))
      (when "group_names | intersect(item.value) | length > 0")
      (loop (jinja "{{ group_mappings | dict2items }}")))))
