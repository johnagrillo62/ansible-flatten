(playbook "kubespray/roles/kubernetes-apps/external_provisioner/local_volume_provisioner/tasks/main.yml"
  (tasks
    (task "Local Volume Provisioner | Ensure base dir is created on all hosts"
      (include_tasks "basedirs.yml")
      (loop_control 
        (loop_var "delegate_host_base_dir"))
      (loop (jinja "{{ groups['k8s_cluster'] | product(local_volume_provisioner_storage_classes.keys()) | list }}")))
    (task "Local Volume Provisioner | Create addon dir"
      (file 
        (path (jinja "{{ kube_config_dir }}") "/addons/local_volume_provisioner")
        (state "directory")
        (owner "root")
        (group "root")
        (mode "0755")))
    (task "Local Volume Provisioner | Templates list"
      (set_fact 
        (local_volume_provisioner_templates (list
            
            (name "local-volume-provisioner-ns")
            (file "local-volume-provisioner-ns.yml")
            (type "ns")
            
            (name "local-volume-provisioner-sa")
            (file "local-volume-provisioner-sa.yml")
            (type "sa")
            
            (name "local-volume-provisioner-clusterrole")
            (file "local-volume-provisioner-clusterrole.yml")
            (type "clusterrole")
            
            (name "local-volume-provisioner-clusterrolebinding")
            (file "local-volume-provisioner-clusterrolebinding.yml")
            (type "clusterrolebinding")
            
            (name "local-volume-provisioner-cm")
            (file "local-volume-provisioner-cm.yml")
            (type "cm")
            
            (name "local-volume-provisioner-ds")
            (file "local-volume-provisioner-ds.yml")
            (type "ds")
            
            (name "local-volume-provisioner-sc")
            (file "local-volume-provisioner-sc.yml")
            (type "sc")))))
    (task "Local Volume Provisioner | Create manifests"
      (template 
        (src (jinja "{{ item.file }}") ".j2")
        (dest (jinja "{{ kube_config_dir }}") "/addons/local_volume_provisioner/" (jinja "{{ item.file }}"))
        (mode "0644"))
      (with_items (jinja "{{ local_volume_provisioner_templates }}"))
      (register "local_volume_provisioner_manifests")
      (when "inventory_hostname == groups['kube_control_plane'][0]"))
    (task "Local Volume Provisioner | Apply manifests"
      (kube 
        (name (jinja "{{ item.item.name }}"))
        (namespace (jinja "{{ local_volume_provisioner_namespace }}"))
        (kubectl (jinja "{{ bin_dir }}") "/kubectl")
        (resource (jinja "{{ item.item.type }}"))
        (filename (jinja "{{ kube_config_dir }}") "/addons/local_volume_provisioner/" (jinja "{{ item.item.file }}"))
        (state "latest"))
      (with_items (jinja "{{ local_volume_provisioner_manifests.results }}"))
      (when "inventory_hostname == groups['kube_control_plane'][0]")
      (loop_control 
        (label (jinja "{{ item.item.file }}"))))))
