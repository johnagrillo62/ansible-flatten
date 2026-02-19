(playbook "kubespray/roles/network_plugin/calico/tasks/peer_with_calico_rr.yml"
  (tasks
    (task "Calico | Set label for groups nodes"
      (command (jinja "{{ bin_dir }}") "/calicoctl.sh label node  " (jinja "{{ inventory_hostname }}") " calico-group-id=" (jinja "{{ calico_group_id }}") " --overwrite")
      (changed_when "false")
      (register "calico_group_id_label")
      (until "calico_group_id_label is succeeded")
      (delay (jinja "{{ retry_stagger | random + 3 }}"))
      (retries "10")
      (when (list
          "calico_group_id is defined")))
    (task "Calico | Configure peering with route reflectors at global scope"
      (command 
        (cmd (jinja "{{ bin_dir }}") "/calicoctl.sh apply -f -")
        (stdin (jinja "{{ stdin is string | ternary(stdin, stdin | to_json) }}")))
      (vars 
        (stdin "{\"apiVersion\": \"projectcalico.org/v3\", \"kind\": \"BGPPeer\", \"metadata\": {
  \"name\": \"" (jinja "{{ calico_rr_id }}") "-to-node\"
}, \"spec\": {
  \"peerSelector\": \"calico-rr-id == '" (jinja "{{ calico_rr_id }}") "'\",
  \"nodeSelector\": \"calico-group-id == '" (jinja "{{ calico_group_id }}") "'\"
}}
"))
      (register "output")
      (retries "4")
      (until "output.rc == 0")
      (delay (jinja "{{ retry_stagger | random + 3 }}"))
      (when (list
          "calico_rr_id is defined"
          "calico_group_id is defined"
          "('calico_rr' in group_names)")))
    (task "Calico | Configure peering with route reflectors at global scope"
      (command 
        (cmd (jinja "{{ bin_dir }}") "/calicoctl.sh apply -f -")
        (stdin (jinja "{{ stdin is string | ternary(stdin, stdin | to_json) }}")))
      (vars 
        (stdin "{\"apiVersion\": \"projectcalico.org/v3\", \"kind\": \"BGPPeer\", \"metadata\": {
  \"name\": \"peer-to-rrs\"
}, \"spec\": {
  \"nodeSelector\": \"!has(i-am-a-route-reflector)\",
  \"peerSelector\": \"has(i-am-a-route-reflector)\"
}}
"))
      (register "output")
      (retries "4")
      (until "output.rc == 0")
      (delay (jinja "{{ retry_stagger | random + 3 }}"))
      (with_items (list
          (jinja "{{ groups['calico_rr'] | default([]) }}")))
      (when (list
          "inventory_hostname == groups['kube_control_plane'][0]"
          "calico_rr_id is not defined or calico_group_id is not defined")))
    (task "Calico | Configure route reflectors to peer with each other"
      (command 
        (cmd (jinja "{{ bin_dir }}") "/calicoctl.sh apply -f -")
        (stdin (jinja "{{ stdin is string | ternary(stdin, stdin | to_json) }}")))
      (vars 
        (stdin "{\"apiVersion\": \"projectcalico.org/v3\", \"kind\": \"BGPPeer\", \"metadata\": {
  \"name\": \"rr-mesh\"
}, \"spec\": {
  \"nodeSelector\": \"has(i-am-a-route-reflector)\",
  \"peerSelector\": \"has(i-am-a-route-reflector)\"
}}
"))
      (register "output")
      (retries "4")
      (until "output.rc == 0")
      (delay (jinja "{{ retry_stagger | random + 3 }}"))
      (with_items (list
          (jinja "{{ groups['calico_rr'] | default([]) }}")))
      (when (list
          "inventory_hostname == groups['kube_control_plane'][0]")))))
