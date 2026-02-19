(playbook "kubespray/roles/kubernetes-apps/external_provisioner/local_path_provisioner/tasks/main.yml"
  (tasks
    (task "Local Path Provisioner | Create addon dir"
      (file 
        (path (jinja "{{ kube_config_dir }}") "/addons/local_path_provisioner")
        (state "directory")
        (owner "root")
        (group "root")
        (mode "0755"))
      (when (list
          "inventory_hostname == groups['kube_control_plane'][0]")))
    (task "Local Path Provisioner | Create claim root dir"
      (file 
        (path (jinja "{{ local_path_provisioner_claim_root }}"))
        (state "directory")
        (mode "0755")))
    (task "Local Path Provisioner | Render Template"
      (set_fact 
        (local_path_provisioner_templates (list
            
            (name "local-path-storage-ns")
            (file "local-path-storage-ns.yml")
            (type "ns")
            
            (name "local-path-storage-sa")
            (file "local-path-storage-sa.yml")
            (type "sa")
            
            (name "local-path-storage-cr")
            (file "local-path-storage-cr.yml")
            (type "cr")
            
            (name "local-path-storage-clusterrolebinding")
            (file "local-path-storage-clusterrolebinding.yml")
            (type "clusterrolebinding")
            
            (name "local-path-storage-cm")
            (file "local-path-storage-cm.yml")
            (type "cm")
            
            (name "local-path-storage-deployment")
            (file "local-path-storage-deployment.yml")
            (type "deployment")
            
            (name "local-path-storage-sc")
            (file "local-path-storage-sc.yml")
            (type "sc")))))
    (task "Local Path Provisioner | Create manifests"
      (template 
        (src (jinja "{{ item.file }}") ".j2")
        (dest (jinja "{{ kube_config_dir }}") "/addons/local_path_provisioner/" (jinja "{{ item.file }}"))
        (mode "0644"))
      (with_items (jinja "{{ local_path_provisioner_templates }}"))
      (register "local_path_provisioner_manifests")
      (when "inventory_hostname == groups['kube_control_plane'][0]"))
    (task "Local Path Provisioner | Apply manifests"
      (kube 
        (name (jinja "{{ item.item.name }}"))
        (namespace (jinja "{{ local_path_provisioner_namespace }}"))
        (kubectl (jinja "{{ bin_dir }}") "/kubectl")
        (resource (jinja "{{ item.item.type }}"))
        (filename (jinja "{{ kube_config_dir }}") "/addons/local_path_provisioner/" (jinja "{{ item.item.file }}"))
        (state "latest"))
      (with_items (jinja "{{ local_path_provisioner_manifests.results }}"))
      (when "inventory_hostname == groups['kube_control_plane'][0]"))))
