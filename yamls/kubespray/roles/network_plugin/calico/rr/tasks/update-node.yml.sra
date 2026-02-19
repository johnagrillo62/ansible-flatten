(playbook "kubespray/roles/network_plugin/calico/rr/tasks/update-node.yml"
  (tasks
    (task "Calico-rr | Configure route reflector"
      (block (list
          
          (name "Set the retry count")
          (set_fact 
            (retry_count (jinja "{{ 0 if retry_count is undefined else retry_count | int + 1 }}")))
          
          (name "Calico | Set label for route reflector")
          (shell (jinja "{{ bin_dir }}") "/calicoctl.sh label node  " (jinja "{{ inventory_hostname }}") " calico-rr-id=" (jinja "{{ calico_rr_id }}") " --overwrite")
          (changed_when "false")
          (register "calico_rr_id_label")
          (until "calico_rr_id_label is succeeded")
          (delay (jinja "{{ retry_stagger | random + 3 }}"))
          (retries "10")
          (when "calico_rr_id is defined")
          
          (name "Calico-rr | Fetch current node object")
          (command (jinja "{{ bin_dir }}") "/calicoctl.sh get node " (jinja "{{ inventory_hostname }}") " -ojson")
          (changed_when "false")
          (register "calico_rr_node")
          (until "calico_rr_node is succeeded")
          (delay (jinja "{{ retry_stagger | random + 3 }}"))
          (retries "10")
          
          (name "Calico-rr | Set route reflector cluster ID")
          (set_fact 
            (calico_rr_node_patched (jinja "{{ calico_rr_node.stdout | from_json | combine({ 'spec': { 'bgp': { 'routeReflectorClusterID': cluster_id }}}, recursive=True) }}")))
          
          (name "Calico-rr | Configure route reflector")
          (shell (jinja "{{ bin_dir }}") "/calicoctl.sh replace -f-")
          (args 
            (stdin (jinja "{{ calico_rr_node_patched | to_json }}")))))
      (rescue (list
          
          (name "Fail if retry limit is reached")
          (fail 
            (msg "Ended after 10 retries"))
          (when "retry_count | int == 10")
          
          (name "Retrying node configuration")
          (debug 
            (msg "Failed to configure route reflector - Retrying..."))
          
          (name "Retry node configuration")
          (include_tasks "update-node.yml"))))))
