(playbook "kubespray/roles/etcd/tasks/gen_nodes_certs_script.yml"
  (tasks
    (task "Gen_certs | Set cert names per node"
      (set_fact 
        (my_etcd_node_certs (list
            "ca.pem"
            "node-" (jinja "{{ inventory_hostname }}") ".pem"
            "node-" (jinja "{{ inventory_hostname }}") "-key.pem")))
      (tags (list
          "facts")))
    (task "Check_certs | Set 'sync_certs' to true on nodes"
      (set_fact 
        (sync_certs "true"))
      (with_items (list
          (jinja "{{ my_etcd_node_certs }}"))))
    (task "Gen_certs | Gather node certs"
      (shell "set -o pipefail && tar cfz - -C " (jinja "{{ etcd_cert_dir }}") " " (jinja "{{ my_etcd_node_certs | join(' ') }}") " | base64 --wrap=0")
      (vars 
        (ansible_ssh_retries "10"))
      (args 
        (executable "/bin/bash"))
      (no_log (jinja "{{ not (unsafe_show_logs | bool) }}"))
      (register "etcd_node_certs")
      (check_mode "false")
      (delegate_to (jinja "{{ groups['etcd'][0] }}"))
      (changed_when "false"))
    (task "Gen_certs | Copy certs on nodes"
      (shell "set -o pipefail && base64 -d <<< '" (jinja "{{ etcd_node_certs.stdout | quote }}") "' | tar xz -C " (jinja "{{ etcd_cert_dir }}"))
      (args 
        (executable "/bin/bash"))
      (no_log (jinja "{{ not (unsafe_show_logs | bool) }}"))
      (changed_when "false"))))
