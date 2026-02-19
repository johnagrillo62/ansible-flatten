(playbook "kubespray/roles/kubernetes/node-label/tasks/main.yml"
  (tasks
    (task "Kubernetes Apps | Wait for kube-apiserver"
      (uri 
        (url (jinja "{{ kube_apiserver_endpoint }}") "/healthz")
        (validate_certs "false")
        (client_cert (jinja "{{ kube_apiserver_client_cert }}"))
        (client_key (jinja "{{ kube_apiserver_client_key }}")))
      (register "result")
      (until "result.status == 200")
      (retries "10")
      (delay "6")
      (when "inventory_hostname == groups['kube_control_plane'][0]"))
    (task "Set role node label to empty list"
      (set_fact 
        (role_node_labels (list))))
    (task "Node label for nvidia GPU nodes"
      (set_fact 
        (role_node_labels (jinja "{{ role_node_labels + ['nvidia.com/gpu=true'] }}")))
      (when (list
          "nvidia_gpu_nodes is defined"
          "nvidia_accelerator_enabled | bool"
          "inventory_hostname in nvidia_gpu_nodes")))
    (task "Set inventory node label to empty list"
      (set_fact 
        (inventory_node_labels (list))))
    (task "Populate inventory node label"
      (set_fact 
        (inventory_node_labels (jinja "{{ inventory_node_labels + ['%s=%s' | format(item.key, item.value)] }}")))
      (loop (jinja "{{ node_labels | d({}) | dict2items }}"))
      (when (list
          "node_labels is defined"
          "node_labels is mapping")))
    (task
      (debug 
        (var "role_node_labels")))
    (task
      (debug 
        (var "inventory_node_labels")))
    (task "Set label to node"
      (command (jinja "{{ kubectl }}") " label node " (jinja "{% if kube_override_hostname %}") (jinja "{{ kube_override_hostname }}") (jinja "{% else %}") (jinja "{{ inventory_hostname }}") (jinja "{% endif %}") " " (jinja "{{ item }}") " --overwrite=true")
      (loop (jinja "{{ role_node_labels + inventory_node_labels }}"))
      (delegate_to (jinja "{{ groups['kube_control_plane'][0] }}"))
      (changed_when "false"))))
