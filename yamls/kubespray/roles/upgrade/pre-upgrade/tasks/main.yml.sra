(playbook "kubespray/roles/upgrade/pre-upgrade/tasks/main.yml"
  (tasks
    (task "Confirm node upgrade"
      (pause 
        (echo "true")
        (prompt "Ready to upgrade node " (jinja "{{ kube_override_hostname | default(inventory_hostname) }}") "? (Press Enter to continue or Ctrl+C for other options)"))
      (when (list
          "upgrade_node_confirm")))
    (task "Wait before upgrade node"
      (pause 
        (seconds (jinja "{{ upgrade_node_pause_seconds }}")))
      (when (list
          "not upgrade_node_confirm"
          "upgrade_node_pause_seconds != 0")))
    (task "See if node is in ready state"
      (command (jinja "{{ kubectl }}") " get node " (jinja "{{ kube_override_hostname | default(inventory_hostname) }}") " -o jsonpath='{ range .status.conditions[?(@.type == \"Ready\")].status }{ @ }{ end }'
")
      (register "kubectl_node_ready")
      (delegate_to (jinja "{{ groups['kube_control_plane'][0] }}"))
      (failed_when "false")
      (changed_when "false"))
    (task "See if node is schedulable"
      (command (jinja "{{ kubectl }}") " get node " (jinja "{{ kube_override_hostname | default(inventory_hostname) }}") " -o jsonpath='{ .spec.unschedulable }'
")
      (register "kubectl_node_unschedulable")
      (delegate_to (jinja "{{ groups['kube_control_plane'][0] }}"))
      (failed_when "false")
      (changed_when "false"))
    (task "Set if node needs cordoning"
      (set_fact 
        (needs_cordoning (jinja "{{ (kubectl_node_ready.stdout == 'True' and not kubectl_node_unschedulable.stdout) or upgrade_node_always_cordon }}"))))
    (task "Node draining"
      (block (list
          
          (name "Cordon node")
          (command (jinja "{{ kubectl }}") " cordon " (jinja "{{ kube_override_hostname | default(inventory_hostname) }}"))
          (delegate_to (jinja "{{ groups['kube_control_plane'][0] }}"))
          (changed_when "true")
          
          (name "Drain node")
          (command (jinja "{{ kubectl }}") " drain --force --ignore-daemonsets --grace-period " (jinja "{{ drain_grace_period }}") " --timeout " (jinja "{{ drain_timeout }}") " --delete-emptydir-data " (jinja "{{ kube_override_hostname | default(inventory_hostname) }}") " " (jinja "{% if drain_pod_selector %}") "--pod-selector '" (jinja "{{ drain_pod_selector }}") "'" (jinja "{% endif %}"))
          (when "drain_nodes")
          (register "result")
          (failed_when (list
              "result.rc != 0"
              "not drain_fallback_enabled"))
          (until "result.rc == 0")
          (retries (jinja "{{ drain_retries }}"))
          (delay (jinja "{{ drain_retry_delay_seconds }}"))
          
          (name "Drain node - fallback with disabled eviction")
          (when (list
              "drain_nodes"
              "drain_fallback_enabled"
              "result.rc != 0"))
          (command (jinja "{{ kubectl }}") " drain --force --ignore-daemonsets --grace-period " (jinja "{{ drain_fallback_grace_period }}") " --timeout " (jinja "{{ drain_fallback_timeout }}") " --delete-emptydir-data " (jinja "{{ kube_override_hostname | default(inventory_hostname) }}") " " (jinja "{% if drain_pod_selector %}") "--pod-selector '" (jinja "{{ drain_pod_selector }}") "'" (jinja "{% endif %}") " --disable-eviction")
          (register "drain_fallback_result")
          (until "drain_fallback_result.rc == 0")
          (retries (jinja "{{ drain_fallback_retries }}"))
          (delay (jinja "{{ drain_fallback_retry_delay_seconds }}"))
          (changed_when "drain_fallback_result.rc == 0")))
      (rescue (list
          
          (name "Set node back to schedulable")
          (command (jinja "{{ kubectl }}") " uncordon " (jinja "{{ kube_override_hostname | default(inventory_hostname) }}"))
          (when "upgrade_node_uncordon_after_drain_failure")
          
          (name "Fail after rescue")
          (fail 
            (msg "Failed to drain node " (jinja "{{ kube_override_hostname | default(inventory_hostname) }}")))
          (when "upgrade_node_fail_if_drain_fails")))
      (delegate_to (jinja "{{ groups['kube_control_plane'][0] }}"))
      (when (list
          "needs_cordoning")))))
