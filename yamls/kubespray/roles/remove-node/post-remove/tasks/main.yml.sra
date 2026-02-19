(playbook "kubespray/roles/remove-node/post-remove/tasks/main.yml"
  (tasks
    (task "Remove-node | Delete node"
      (command (jinja "{{ kubectl }}") " delete node " (jinja "{{ kube_override_hostname }}"))
      (delegate_to (jinja "{{ groups['kube_control_plane'] | first }}"))
      (when (list
          "groups['kube_control_plane'] | length > 0"
          "('k8s_cluster' in group_names) and kube_override_hostname in nodes.stdout_lines"))
      (retries (jinja "{{ delete_node_retries }}"))
      (delay (jinja "{{ delete_node_delay_seconds }}"))
      (register "result")
      (until "result is not failed"))))
