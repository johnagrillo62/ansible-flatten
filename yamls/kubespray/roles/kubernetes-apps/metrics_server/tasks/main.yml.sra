(playbook "kubespray/roles/kubernetes-apps/metrics_server/tasks/main.yml"
  (tasks
    (task "Metrics Server | Delete addon dir"
      (file 
        (path (jinja "{{ kube_config_dir }}") "/addons/metrics_server")
        (state "absent"))
      (when (list
          "inventory_hostname == groups['kube_control_plane'][0]"))
      (tags (list
          "upgrade")))
    (task "Metrics Server | Create addon dir"
      (file 
        (path (jinja "{{ kube_config_dir }}") "/addons/metrics_server")
        (state "directory")
        (owner "root")
        (group "root")
        (mode "0755"))
      (when (list
          "inventory_hostname == groups['kube_control_plane'][0]")))
    (task "Metrics Server | Templates list"
      (set_fact 
        (metrics_server_templates (list
            
            (name "auth-delegator")
            (file "auth-delegator.yaml")
            (type "clusterrolebinding")
            
            (name "auth-reader")
            (file "auth-reader.yaml")
            (type "rolebinding")
            
            (name "metrics-server-sa")
            (file "metrics-server-sa.yaml")
            (type "sa")
            
            (name "metrics-server-deployment")
            (file "metrics-server-deployment.yaml")
            (type "deploy")
            
            (name "metrics-server-service")
            (file "metrics-server-service.yaml")
            (type "service")
            
            (name "metrics-apiservice")
            (file "metrics-apiservice.yaml")
            (type "service")
            
            (name "resource-reader-clusterrolebinding")
            (file "resource-reader-clusterrolebinding.yaml")
            (type "clusterrolebinding")
            
            (name "resource-reader")
            (file "resource-reader.yaml")
            (type "clusterrole")))))
    (task "Metrics Server | Create manifests"
      (template 
        (src (jinja "{{ item.file }}") ".j2")
        (dest (jinja "{{ kube_config_dir }}") "/addons/metrics_server/" (jinja "{{ item.file }}"))
        (mode "0644"))
      (with_items (jinja "{{ metrics_server_templates }}"))
      (register "metrics_server_manifests")
      (when (list
          "inventory_hostname == groups['kube_control_plane'][0]")))
    (task "Metrics Server | Apply manifests"
      (kube 
        (name (jinja "{{ item.item.name }}"))
        (kubectl (jinja "{{ bin_dir }}") "/kubectl")
        (resource (jinja "{{ item.item.type }}"))
        (filename (jinja "{{ kube_config_dir }}") "/addons/metrics_server/" (jinja "{{ item.item.file }}"))
        (state "latest"))
      (with_items (jinja "{{ metrics_server_manifests.results }}"))
      (when (list
          "inventory_hostname == groups['kube_control_plane'][0]")))))
