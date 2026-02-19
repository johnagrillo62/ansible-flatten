(playbook "kubespray/roles/network_plugin/calico/tasks/peer_with_router.yml"
  (tasks
    (task "Calico | Configure peering with router(s) at global scope"
      (command 
        (cmd (jinja "{{ bin_dir }}") "/calicoctl.sh apply -f -")
        (stdin (jinja "{{ stdin is string | ternary(stdin, stdin | to_json) }}")))
      (vars 
        (stdin "{\"apiVersion\": \"projectcalico.org/v3\", \"kind\": \"BGPPeer\", \"metadata\": {
  \"name\": \"global-" (jinja "{{ item.name | default(item.router_id | replace(':', '-')) }}") "\"
}, \"spec\": {
  \"asNumber\": \"" (jinja "{{ item.as }}") "\",
  \"peerIP\": \"" (jinja "{{ item.router_id }}") "\"
}}
"))
      (register "output")
      (retries "4")
      (until "output.rc == 0")
      (delay (jinja "{{ retry_stagger | random + 3 }}"))
      (with_items (list
          (jinja "{{ peers | default([]) | selectattr('scope', 'defined') | selectattr('scope', 'equalto', 'global') | list }}")))
      (when (list
          "inventory_hostname == groups['kube_control_plane'][0]")))
    (task "Calico | Get node for per node peering"
      (command 
        (cmd (jinja "{{ bin_dir }}") "/calicoctl.sh get node " (jinja "{{ inventory_hostname }}")))
      (register "output_get_node")
      (when (list
          "('k8s_cluster' in group_names)"
          "local_as is defined"
          "groups['calico_rr'] | default([]) | length == 0"))
      (delegate_to (jinja "{{ groups['kube_control_plane'][0] }}")))
    (task "Calico | Patch node asNumber for per node peering"
      (command 
        (cmd (jinja "{{ bin_dir }}") "/calicoctl.sh patch node \"" (jinja "{{ inventory_hostname }}") "\" --patch '" (jinja "{{ patch is string | ternary(patch, patch | to_json) }}") "'"))
      (vars 
        (patch "{\"spec\": {
  \"bgp\": {
    \"asNumber\": \"" (jinja "{{ local_as }}") "\"
  },
  \"orchRefs\": [{\"nodeName\": \"" (jinja "{{ inventory_hostname }}") "\", \"orchestrator\": \"k8s\"}]
}}
"))
      (register "output")
      (retries "0")
      (until "output.rc == 0")
      (delay (jinja "{{ retry_stagger | random + 3 }}"))
      (when (list
          "('k8s_cluster' in group_names)"
          "local_as is defined"
          "groups['calico_rr'] | default([]) | length == 0"
          "output_get_node.rc == 0")))
    (task "Calico | Configure node asNumber for per node peering"
      (command 
        (cmd (jinja "{{ bin_dir }}") "/calicoctl.sh apply -f -")
        (stdin (jinja "{{ stdin is string | ternary(stdin, stdin | to_json) }}")))
      (vars 
        (stdin "{\"apiVersion\": \"projectcalico.org/v3\", \"kind\": \"Node\", \"metadata\": {
  \"name\": \"" (jinja "{{ inventory_hostname }}") "\"
}, \"spec\": {
  \"bgp\": {
    \"asNumber\": \"" (jinja "{{ local_as }}") "\"
  },
  \"orchRefs\":[{\"nodeName\":\"" (jinja "{{ inventory_hostname }}") "\",\"orchestrator\":\"k8s\"}]
}}
"))
      (register "output")
      (retries "4")
      (until "output.rc == 0")
      (delay (jinja "{{ retry_stagger | random + 3 }}"))
      (when (list
          "('k8s_cluster' in group_names)"
          "local_as is defined"
          "groups['calico_rr'] | default([]) | length == 0"
          "output_get_node.rc != 0")))
    (task "Calico | Configure peering with router(s) at node scope"
      (command 
        (cmd (jinja "{{ bin_dir }}") "/calicoctl.sh apply -f -")
        (stdin (jinja "{{ stdin is string | ternary(stdin, stdin | to_json) }}")))
      (vars 
        (stdin "{\"apiVersion\": \"projectcalico.org/v3\", \"kind\": \"BGPPeer\", \"metadata\": {
  \"name\": \"" (jinja "{{ inventory_hostname }}") "-" (jinja "{{ item.name | default(item.router_id | replace(':', '-')) }}") "\"
}, \"spec\": {
  \"asNumber\": \"" (jinja "{{ item.as }}") "\",
  \"node\": \"" (jinja "{{ inventory_hostname }}") "\",
  \"peerIP\": \"" (jinja "{{ item.router_id }}") "\",
  " (jinja "{% if calico_version is version('3.26.0', '>=') and (item.filters | default([]) | length > 0) %}") "
  \"filters\": " (jinja "{{ item.filters }}") ",
  " (jinja "{% endif %}") "
  " (jinja "{% if calico_version is version('3.23.0', '>=') and (item.numallowedlocalasnumbers | default(0) > 0) %}") "
  \"numAllowedLocalASNumbers\": " (jinja "{{ item.numallowedlocalasnumbers }}") ",
  " (jinja "{% endif %}") "
  \"sourceAddress\": \"" (jinja "{{ item.sourceaddress | default('UseNodeIP') }}") "\"
}}
"))
      (register "output")
      (retries "4")
      (until "output.rc == 0")
      (delay (jinja "{{ retry_stagger | random + 3 }}"))
      (with_items (list
          (jinja "{{ peers | default([]) | selectattr('scope', 'undefined') | list | union(peers | default([]) | selectattr('scope', 'defined') | selectattr('scope', 'equalto', 'node') | list ) }}")))
      (delegate_to (jinja "{{ groups['kube_control_plane'][0] }}"))
      (when (list
          "('k8s_cluster' in group_names)")))))
