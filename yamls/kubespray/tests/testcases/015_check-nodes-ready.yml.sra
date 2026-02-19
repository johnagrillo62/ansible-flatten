(playbook "kubespray/tests/testcases/015_check-nodes-ready.yml"
  (tasks
    (task
      (import_role 
        (name "cluster-dump")))
    (task "Check kubectl output"
      (command (jinja "{{ bin_dir }}") "/kubectl get nodes")
      (changed_when "false")
      (register "get_nodes"))
    (task "Check that all nodes are running and ready"
      (command (jinja "{{ bin_dir }}") "/kubectl get nodes --no-headers -o yaml")
      (changed_when "false")
      (register "get_nodes_yaml")
      (until (list
          "(get_nodes_yaml.stdout | from_yaml)[\"items\"] | map(attribute = \"status.conditions\") | map(\"items2dict\", key_name=\"type\", value_name=\"status\") | map(attribute=\"Ready\") | list | min"))
      (retries "30")
      (delay "10"))))
