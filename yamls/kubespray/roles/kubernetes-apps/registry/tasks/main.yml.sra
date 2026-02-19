(playbook "kubespray/roles/kubernetes-apps/registry/tasks/main.yml"
  (tasks
    (task "Registry | check registry_service_type value"
      (fail 
        (msg "registry_service_type can only be 'ClusterIP', 'LoadBalancer' or 'NodePort'"))
      (when "registry_service_type not in ['ClusterIP', 'LoadBalancer', 'NodePort']"))
    (task "Registry | Stop if registry_service_cluster_ip is defined when registry_service_type is not 'ClusterIP'"
      (fail 
        (msg "registry_service_cluster_ip support only compatible with ClusterIP."))
      (when (list
          "registry_service_cluster_ip is defined and registry_service_cluster_ip | length > 0"
          "registry_service_type != \"ClusterIP\"")))
    (task "Registry | Stop if registry_service_loadbalancer_ip is defined when registry_service_type is not 'LoadBalancer'"
      (fail 
        (msg "registry_service_loadbalancer_ip support only compatible with LoadBalancer."))
      (when (list
          "registry_service_loadbalancer_ip is defined and registry_service_loadbalancer_ip | length > 0"
          "registry_service_type != \"LoadBalancer\"")))
    (task "Registry | Stop if registry_service_nodeport is defined when registry_service_type is not 'NodePort'"
      (fail 
        (msg "registry_service_nodeport support only compatible with NodePort."))
      (when (list
          "registry_service_nodeport is defined and registry_service_nodeport | length > 0"
          "registry_service_type != \"NodePort\"")))
    (task "Registry | Create addon dir"
      (file 
        (path (jinja "{{ kube_config_dir }}") "/addons/registry")
        (state "directory")
        (owner "root")
        (group "root")
        (mode "0755")))
    (task "Registry | Templates list"
      (set_fact 
        (registry_templates (list
            
            (name "registry-ns")
            (file "registry-ns.yml")
            (type "ns")
            
            (name "registry-sa")
            (file "registry-sa.yml")
            (type "sa")
            
            (name "registry-svc")
            (file "registry-svc.yml")
            (type "svc")
            
            (name "registry-secrets")
            (file "registry-secrets.yml")
            (type "secrets")
            
            (name "registry-cm")
            (file "registry-cm.yml")
            (type "cm")
            
            (name "registry-rs")
            (file "registry-rs.yml")
            (type "rs")))))
    (task "Registry | Append ingress templates to Registry Templates list when ALB ingress enabled"
      (set_fact 
        (registry_templates (jinja "{{ registry_templates + [item] }}")))
      (with_items (list
          (list
            
            (name "registry-ing")
            (file "registry-ing.yml")
            (type "ing"))))
      (when "ingress_alb_enabled"))
    (task "Registry | Create manifests"
      (template 
        (src (jinja "{{ item.file }}") ".j2")
        (dest (jinja "{{ kube_config_dir }}") "/addons/registry/" (jinja "{{ item.file }}"))
        (mode "0644"))
      (with_items (jinja "{{ registry_templates }}"))
      (register "registry_manifests")
      (when "inventory_hostname == groups['kube_control_plane'][0]"))
    (task "Registry | Apply manifests"
      (kube 
        (name (jinja "{{ item.item.name }}"))
        (namespace (jinja "{{ registry_namespace }}"))
        (kubectl (jinja "{{ bin_dir }}") "/kubectl")
        (resource (jinja "{{ item.item.type }}"))
        (filename (jinja "{{ kube_config_dir }}") "/addons/registry/" (jinja "{{ item.item.file }}"))
        (state "latest"))
      (with_items (jinja "{{ registry_manifests.results }}"))
      (when "inventory_hostname == groups['kube_control_plane'][0]"))
    (task "Registry | Create PVC manifests"
      (template 
        (src (jinja "{{ item.file }}") ".j2")
        (dest (jinja "{{ kube_config_dir }}") "/addons/registry/" (jinja "{{ item.file }}"))
        (mode "0644"))
      (with_items (list
          
          (name "registry-pvc")
          (file "registry-pvc.yml")
          (type "pvc")))
      (register "registry_manifests")
      (when (list
          "registry_storage_class != none and registry_storage_class"
          "registry_disk_size != none and registry_disk_size"
          "inventory_hostname == groups['kube_control_plane'][0]")))
    (task "Registry | Apply PVC manifests"
      (kube 
        (name (jinja "{{ item.item.name }}"))
        (namespace (jinja "{{ registry_namespace }}"))
        (kubectl (jinja "{{ bin_dir }}") "/kubectl")
        (resource (jinja "{{ item.item.type }}"))
        (filename (jinja "{{ kube_config_dir }}") "/addons/registry/" (jinja "{{ item.item.file }}"))
        (state "latest"))
      (with_items (jinja "{{ registry_manifests.results }}"))
      (when (list
          "registry_storage_class != none and registry_storage_class"
          "registry_disk_size != none and registry_disk_size"
          "inventory_hostname == groups['kube_control_plane'][0]")))))
