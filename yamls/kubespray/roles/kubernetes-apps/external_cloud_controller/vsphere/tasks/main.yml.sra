(playbook "kubespray/roles/kubernetes-apps/external_cloud_controller/vsphere/tasks/main.yml"
  (tasks
    (task "External vSphere Cloud Controller | Check vsphere credentials"
      (include_tasks "vsphere-credentials-check.yml"))
    (task "External vSphere Cloud Controller | Generate CPI cloud-config"
      (template 
        (src (jinja "{{ item }}") ".j2")
        (dest (jinja "{{ kube_config_dir }}") "/" (jinja "{{ item }}"))
        (mode "0640"))
      (with_items (list
          "external-vsphere-cpi-cloud-config"))
      (when "inventory_hostname == groups['kube_control_plane'][0]"))
    (task "External vSphere Cloud Controller | Generate Manifests"
      (template 
        (src (jinja "{{ item }}") ".j2")
        (dest (jinja "{{ kube_config_dir }}") "/" (jinja "{{ item }}"))
        (mode "0644"))
      (with_items (list
          "external-vsphere-cpi-cloud-config-secret.yml"
          "external-vsphere-cloud-controller-manager-roles.yml"
          "external-vsphere-cloud-controller-manager-role-bindings.yml"
          "external-vsphere-cloud-controller-manager-ds.yml"))
      (register "external_vsphere_manifests")
      (when "inventory_hostname == groups['kube_control_plane'][0]"))
    (task "External vSphere Cloud Provider Interface | Create a CPI configMap manifest"
      (command (jinja "{{ bin_dir }}") "/kubectl create configmap cloud-config --from-file=vsphere.conf=" (jinja "{{ kube_config_dir }}") "/external-vsphere-cpi-cloud-config -n kube-system --dry-run --save-config -o yaml")
      (register "external_vsphere_configmap_manifest")
      (when "inventory_hostname == groups['kube_control_plane'][0]"))
    (task "External vSphere Cloud Provider Interface | Apply a CPI configMap manifest"
      (command 
        (cmd (jinja "{{ bin_dir }}") "/kubectl apply -f -")
        (stdin (jinja "{{ external_vsphere_configmap_manifest.stdout }}")))
      (when "inventory_hostname == groups['kube_control_plane'][0]"))
    (task "External vSphere Cloud Controller | Apply Manifests"
      (kube 
        (kubectl (jinja "{{ bin_dir }}") "/kubectl")
        (filename (jinja "{{ kube_config_dir }}") "/" (jinja "{{ item.item }}"))
        (state "latest"))
      (with_items (list
          (jinja "{{ external_vsphere_manifests.results }}")))
      (when (list
          "inventory_hostname == groups['kube_control_plane'][0]"
          "not item is skipped"))
      (loop_control 
        (label (jinja "{{ item.item }}"))))))
