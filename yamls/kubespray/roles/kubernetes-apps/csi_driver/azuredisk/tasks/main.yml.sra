(playbook "kubespray/roles/kubernetes-apps/csi_driver/azuredisk/tasks/main.yml"
  (tasks
    (task "Azure CSI Driver | Check Azure credentials"
      (include_tasks "azure-credential-check.yml"))
    (task "Azure CSI Driver | Write Azure CSI cloud-config"
      (template 
        (src "azure-csi-cloud-config.j2")
        (dest (jinja "{{ kube_config_dir }}") "/azure_csi_cloud_config")
        (group (jinja "{{ kube_cert_group }}"))
        (mode "0640"))
      (when "inventory_hostname == groups['kube_control_plane'][0]"))
    (task "Azure CSI Driver | Get base64 cloud-config"
      (slurp 
        (src (jinja "{{ kube_config_dir }}") "/azure_csi_cloud_config"))
      (register "cloud_config_secret")
      (when "inventory_hostname == groups['kube_control_plane'][0]"))
    (task "Azure CSI Driver | Generate Manifests"
      (template 
        (src (jinja "{{ item.file }}") ".j2")
        (dest (jinja "{{ kube_config_dir }}") "/" (jinja "{{ item.file }}"))
        (mode "0644"))
      (with_items (list
          
          (name "azure-csi-azuredisk-driver")
          (file "azure-csi-azuredisk-driver.yml")
          
          (name "azure-csi-cloud-config-secret")
          (file "azure-csi-cloud-config-secret.yml")
          
          (name "azure-csi-azuredisk-controller")
          (file "azure-csi-azuredisk-controller-rbac.yml")
          
          (name "azure-csi-azuredisk-controller")
          (file "azure-csi-azuredisk-controller.yml")
          
          (name "azure-csi-azuredisk-node-rbac")
          (file "azure-csi-azuredisk-node-rbac.yml")
          
          (name "azure-csi-azuredisk-node")
          (file "azure-csi-azuredisk-node.yml")))
      (register "azure_csi_manifests")
      (when "inventory_hostname == groups['kube_control_plane'][0]"))
    (task "Azure CSI Driver | Apply Manifests"
      (kube 
        (kubectl (jinja "{{ bin_dir }}") "/kubectl")
        (filename (jinja "{{ kube_config_dir }}") "/" (jinja "{{ item.item.file }}"))
        (state "latest"))
      (with_items (list
          (jinja "{{ azure_csi_manifests.results }}")))
      (when (list
          "inventory_hostname == groups['kube_control_plane'][0]"
          "not item is skipped"))
      (loop_control 
        (label (jinja "{{ item.item.file }}"))))))
