(playbook "kubespray/roles/network_plugin/kube-router/tasks/annotate.yml"
  (tasks
    (task "Kube-router | Add annotations on kube_control_plane"
      (command (jinja "{{ kubectl }}") " annotate --overwrite node " (jinja "{{ ansible_hostname }}") " " (jinja "{{ item }}"))
      (with_items (list
          (jinja "{{ kube_router_annotations_master }}")))
      (delegate_to (jinja "{{ groups['kube_control_plane'][0] }}"))
      (when "kube_router_annotations_master is defined and 'kube_control_plane' in group_names"))
    (task "Kube-router | Add annotations on kube_node"
      (command (jinja "{{ kubectl }}") " annotate --overwrite node " (jinja "{{ ansible_hostname }}") " " (jinja "{{ item }}"))
      (with_items (list
          (jinja "{{ kube_router_annotations_node }}")))
      (delegate_to (jinja "{{ groups['kube_control_plane'][0] }}"))
      (when "kube_router_annotations_node is defined and 'kube_node' in group_names"))
    (task "Kube-router | Add common annotations on all servers"
      (command (jinja "{{ kubectl }}") " annotate --overwrite node " (jinja "{{ ansible_hostname }}") " " (jinja "{{ item }}"))
      (with_items (list
          (jinja "{{ kube_router_annotations_all }}")))
      (delegate_to (jinja "{{ groups['kube_control_plane'][0] }}"))
      (when "kube_router_annotations_all is defined and 'k8s_cluster' in group_names"))))
