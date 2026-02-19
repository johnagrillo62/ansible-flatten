(playbook "kubespray/roles/kubernetes-apps/csi_driver/cinder/tasks/main.yml"
  (tasks
    (task "Cinder CSI Driver | Check Cinder credentials"
      (include_tasks "cinder-credential-check.yml"))
    (task "Cinder CSI Driver | Write cacert file"
      (include_tasks "cinder-write-cacert.yml")
      (run_once "true")
      (loop (jinja "{{ groups['k8s_cluster'] }}"))
      (loop_control 
        (loop_var "delegate_host_to_write_cacert"))
      (when (list
          "('k8s_cluster' in group_names)"
          "cinder_cacert is defined"
          "cinder_cacert | length > 0")))
    (task "Cinder CSI Driver | Write Cinder cloud-config"
      (template 
        (src "cinder-csi-cloud-config.j2")
        (dest (jinja "{{ kube_config_dir }}") "/cinder_cloud_config")
        (group (jinja "{{ kube_cert_group }}"))
        (mode "0640"))
      (when "inventory_hostname == groups['kube_control_plane'][0]"))
    (task "Cinder CSI Driver | Get base64 cloud-config"
      (slurp 
        (src (jinja "{{ kube_config_dir }}") "/cinder_cloud_config"))
      (register "cloud_config_secret")
      (when "inventory_hostname == groups['kube_control_plane'][0]"))
    (task "Cinder CSI Driver | Generate Manifests"
      (template 
        (src (jinja "{{ item.file }}") ".j2")
        (dest (jinja "{{ kube_config_dir }}") "/" (jinja "{{ item.file }}"))
        (mode "0644"))
      (with_items (list
          
          (name "cinder-csi-driver")
          (file "cinder-csi-driver.yml")
          
          (name "cinder-csi-cloud-config-secret")
          (file "cinder-csi-cloud-config-secret.yml")
          
          (name "cinder-csi-controllerplugin")
          (file "cinder-csi-controllerplugin-rbac.yml")
          
          (name "cinder-csi-controllerplugin")
          (file "cinder-csi-controllerplugin.yml")
          
          (name "cinder-csi-nodeplugin")
          (file "cinder-csi-nodeplugin-rbac.yml")
          
          (name "cinder-csi-nodeplugin")
          (file "cinder-csi-nodeplugin.yml")
          
          (name "cinder-csi-poddisruptionbudget")
          (file "cinder-csi-poddisruptionbudget.yml")))
      (register "cinder_csi_manifests")
      (when "inventory_hostname == groups['kube_control_plane'][0]"))
    (task "Cinder CSI Driver | Apply Manifests"
      (kube 
        (kubectl (jinja "{{ bin_dir }}") "/kubectl")
        (filename (jinja "{{ kube_config_dir }}") "/" (jinja "{{ item.item.file }}"))
        (state "latest"))
      (with_items (list
          (jinja "{{ cinder_csi_manifests.results }}")))
      (when (list
          "inventory_hostname == groups['kube_control_plane'][0]"
          "not item is skipped"))
      (loop_control 
        (label (jinja "{{ item.item.file }}"))))))
