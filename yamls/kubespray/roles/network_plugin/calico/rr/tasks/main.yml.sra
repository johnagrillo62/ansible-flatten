(playbook "kubespray/roles/network_plugin/calico/rr/tasks/main.yml"
  (tasks
    (task "Calico-rr | Pre-upgrade tasks"
      (include_tasks "pre.yml"))
    (task "Calico-rr | Configuring node tasks"
      (include_tasks "update-node.yml"))
    (task "Calico-rr | Set label for route reflector"
      (command (jinja "{{ bin_dir }}") "/calicoctl.sh label node " (jinja "{{ inventory_hostname }}") " 'i-am-a-route-reflector=true' --overwrite")
      (changed_when "false")
      (register "calico_rr_label")
      (until "calico_rr_label is succeeded")
      (delay (jinja "{{ retry_stagger | random + 3 }}"))
      (retries "10"))))
