(playbook "kubespray/roles/kubernetes/node-taint/tasks/main.yml"
  (tasks
    (task "Set role and inventory node taint to empty list"
      (set_fact 
        (role_node_taints (list))
        (inventory_node_taints (list))))
    (task "Node taint for nvidia GPU nodes"
      (set_fact 
        (role_node_taints (jinja "{{ role_node_taints + ['nvidia.com/gpu=:NoSchedule'] }}")))
      (when (list
          "nvidia_gpu_nodes is defined"
          "nvidia_accelerator_enabled | bool"
          "inventory_hostname in nvidia_gpu_nodes")))
    (task "Populate inventory node taint"
      (set_fact 
        (inventory_node_taints (jinja "{{ inventory_node_taints + node_taints }}")))
      (when (list
          "node_taints is defined"
          "node_taints is not string"
          "node_taints is not mapping"
          "node_taints is iterable")))
    (task
      (debug 
        (var "role_node_taints")))
    (task
      (debug 
        (var "inventory_node_taints")))
    (task "Set taint to node"
      (command (jinja "{{ kubectl }}") " taint node " (jinja "{{ kube_override_hostname | default(inventory_hostname) }}") " " (jinja "{{ (role_node_taints + inventory_node_taints) | join(' ') }}") " --overwrite=true")
      (delegate_to (jinja "{{ groups['kube_control_plane'][0] }}"))
      (changed_when "false")
      (when (list
          "(role_node_taints + inventory_node_taints) | length > 0")))))
