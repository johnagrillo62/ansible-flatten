(playbook "kubespray/roles/upgrade/post-upgrade/tasks/main.yml"
  (tasks
    (task "Wait for cilium"
      (command (jinja "{{ kubectl }}") " wait pod -n kube-system -l k8s-app=cilium --field-selector 'spec.nodeName==" (jinja "{{ kube_override_hostname | default(inventory_hostname) }}") "' --for=condition=Ready --timeout=" (jinja "{{ upgrade_post_cilium_wait_timeout }}") "
")
      (when (list
          "needs_cordoning | default(false)"
          "kube_network_plugin == 'cilium'"))
      (delegate_to (jinja "{{ groups['kube_control_plane'][0] }}")))
    (task "Confirm node uncordon"
      (pause 
        (echo "true")
        (prompt "Ready to uncordon node " (jinja "{{ kube_override_hostname | default(inventory_hostname) }}") "?"))
      (when (list
          "upgrade_node_post_upgrade_confirm")))
    (task "Wait before uncordoning node"
      (pause 
        (seconds (jinja "{{ upgrade_node_post_upgrade_pause_seconds }}")))
      (when (list
          "not upgrade_node_post_upgrade_confirm"
          "upgrade_node_post_upgrade_pause_seconds != 0")))
    (task "Run post upgrade hooks before uncordon"
      (ansible.builtin.include_tasks (jinja "{{ item }}"))
      (loop (jinja "{{ post_upgrade_hooks | default([]) }}")))
    (task "Uncordon node"
      (command (jinja "{{ kubectl }}") " uncordon " (jinja "{{ kube_override_hostname | default(inventory_hostname) }}"))
      (delegate_to (jinja "{{ groups['kube_control_plane'][0] }}"))
      (when (list
          "needs_cordoning | default(false)")))))
