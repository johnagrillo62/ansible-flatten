(playbook "kubespray/roles/kubernetes-apps/node_feature_discovery/tasks/main.yml"
  (tasks
    (task "Node Feature Discovery | Create addon dir"
      (file 
        (path (jinja "{{ kube_config_dir }}") "/addons/node_feature_discovery")
        (state "directory")
        (owner "root")
        (group "root")
        (mode "0755"))
      (when (list
          "inventory_hostname == groups['kube_control_plane'][0]")))
    (task "Node Feature Discovery | Templates list"
      (set_fact 
        (node_feature_discovery_templates (list
            
            (name "nfd-ns")
            (file "nfd-ns.yaml")
            (type "ns")
            
            (name "nfd-api-crd")
            (file "nfd-api-crds.yaml")
            (type "crd")
            
            (name "nfd-serviceaccount")
            (file "nfd-serviceaccount.yaml")
            (type "sa")
            
            (name "nfd-role")
            (file "nfd-role.yaml")
            (type "role")
            
            (name "nfd-clusterrole")
            (file "nfd-clusterrole.yaml")
            (type "clusterrole")
            
            (name "nfd-rolebinding")
            (file "nfd-rolebinding.yaml")
            (type "rolebinding")
            
            (name "nfd-clusterrolebinding")
            (file "nfd-clusterrolebinding.yaml")
            (type "clusterrolebinding")
            
            (name "nfd-master-conf")
            (file "nfd-master-conf.yaml")
            (type "cm")
            
            (name "nfd-worker-conf")
            (file "nfd-worker-conf.yaml")
            (type "cm")
            
            (name "nfd-topologyupdater-conf")
            (file "nfd-topologyupdater-conf.yaml")
            (type "cm")
            
            (name "nfd-gc")
            (file "nfd-gc.yaml")
            (type "deploy")
            
            (name "nfd-master")
            (file "nfd-master.yaml")
            (type "deploy")
            
            (name "nfd-worker")
            (file "nfd-worker.yaml")
            (type "ds")
            
            (name "nfd-service")
            (file "nfd-service.yaml")
            (type "srv")))))
    (task "Node Feature Discovery | Create manifests"
      (template 
        (src (jinja "{{ item.file }}") ".j2")
        (dest (jinja "{{ kube_config_dir }}") "/addons/node_feature_discovery/" (jinja "{{ item.file }}"))
        (mode "0644"))
      (with_items (jinja "{{ node_feature_discovery_templates }}"))
      (register "node_feature_discovery_manifests")
      (when (list
          "inventory_hostname == groups['kube_control_plane'][0]")))
    (task "Node Feature Discovery | Apply manifests"
      (kube 
        (name (jinja "{{ item.item.name }}"))
        (kubectl (jinja "{{ bin_dir }}") "/kubectl")
        (resource (jinja "{{ item.item.type }}"))
        (filename (jinja "{{ kube_config_dir }}") "/addons/node_feature_discovery/" (jinja "{{ item.item.file }}"))
        (state "latest"))
      (with_items (jinja "{{ node_feature_discovery_manifests.results }}"))
      (when (list
          "inventory_hostname == groups['kube_control_plane'][0]")))))
