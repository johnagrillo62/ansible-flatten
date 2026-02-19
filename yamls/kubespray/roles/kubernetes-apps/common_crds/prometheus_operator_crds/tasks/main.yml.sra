(playbook "kubespray/roles/kubernetes-apps/common_crds/prometheus_operator_crds/tasks/main.yml"
  (tasks
    (task "Prometheus Operator CRDs | Download YAML"
      (include_tasks "../../../../download/tasks/download_file.yml")
      (vars 
        (download (jinja "{{ download_defaults | combine(downloads.prometheus_operator_crds) }}"))))
    (task "Prometheus Operator CRDs | Install"
      (command 
        (cmd (jinja "{{ bin_dir }}") "/kubectl apply -f " (jinja "{{ local_release_dir }}") "/prometheus-operator-crds.yaml"))
      (when (list
          "inventory_hostname == groups['kube_control_plane'][0]")))))
