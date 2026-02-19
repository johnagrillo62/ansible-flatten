(playbook "openshift-ansible/roles/openshift_node/tasks/scaleup_checks.yml"
  (tasks
    (task "Ensure [new_workers] group is populated"
      (fail 
        (msg "Detected no [new_workers] in inventory. Please add hosts to the [new_workers] host group to add nodes.
"))
      (when "groups.new_workers | default([]) | length == 0"))
    (task "Get cluster nodes"
      (command "oc get nodes --kubeconfig=" (jinja "{{ openshift_node_kubeconfig_path }}") " --output=name
")
      (register "oc_get")
      (until (list
          "oc_get.stdout != ''"))
      (retries "36")
      (delay "5")
      (changed_when "false"))
    (task "Check for nodes which are already part of the cluster"
      (set_fact 
        (openshift_node_active_nodes (jinja "{{ openshift_node_active_nodes + [ item ] }}")))
      (when "item in oc_get.stdout")
      (loop (jinja "{{ groups.new_workers }}")))
    (task "Fail if new_workers group contains active nodes"
      (fail 
        (msg "Detected active nodes in [new_workers] group. Please move these nodes to the [workers] group. " (jinja "{{ openshift_node_active_nodes | join(', ') }}") "
"))
      (when "openshift_node_active_nodes | length > 0"))))
