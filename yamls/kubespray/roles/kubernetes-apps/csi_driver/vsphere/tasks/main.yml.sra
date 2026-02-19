(playbook "kubespray/roles/kubernetes-apps/csi_driver/vsphere/tasks/main.yml"
  (tasks
    (task "VSphere CSI Driver | Check vsphare credentials"
      (include_tasks "vsphere-credentials-check.yml"))
    (task "VSphere CSI Driver | Generate CSI cloud-config"
      (template 
        (src (jinja "{{ item }}") ".j2")
        (dest (jinja "{{ kube_config_dir }}") "/" (jinja "{{ item }}"))
        (mode "0640"))
      (with_items (list
          "vsphere-csi-cloud-config"))
      (when "inventory_hostname == groups['kube_control_plane'][0]"))
    (task "VSphere CSI Driver | Generate Manifests"
      (template 
        (src (jinja "{{ item }}") ".j2")
        (dest (jinja "{{ kube_config_dir }}") "/" (jinja "{{ item }}"))
        (mode "0644"))
      (with_items (list
          "vsphere-csi-namespace.yml"
          "vsphere-csi-driver.yml"
          "vsphere-csi-controller-rbac.yml"
          "vsphere-csi-node-rbac.yml"
          "vsphere-csi-controller-config.yml"
          "vsphere-csi-controller-deployment.yml"
          "vsphere-csi-controller-service.yml"
          "vsphere-csi-node.yml"))
      (register "vsphere_csi_manifests")
      (when "inventory_hostname == groups['kube_control_plane'][0]"))
    (task "VSphere CSI Driver | Apply Manifests"
      (kube 
        (kubectl (jinja "{{ bin_dir }}") "/kubectl")
        (filename (jinja "{{ kube_config_dir }}") "/" (jinja "{{ item.item }}"))
        (state "latest"))
      (with_items (list
          (jinja "{{ vsphere_csi_manifests.results }}")))
      (when (list
          "inventory_hostname == groups['kube_control_plane'][0]"
          "not item is skipped"))
      (loop_control 
        (label (jinja "{{ item.item }}"))))
    (task "VSphere CSI Driver | Generate a CSI secret manifest"
      (command (jinja "{{ kubectl }}") " create secret generic vsphere-config-secret --from-file=csi-vsphere.conf=" (jinja "{{ kube_config_dir }}") "/vsphere-csi-cloud-config -n " (jinja "{{ vsphere_csi_namespace }}") " --dry-run --save-config -o yaml")
      (register "vsphere_csi_secret_manifest")
      (when "inventory_hostname == groups['kube_control_plane'][0]")
      (no_log (jinja "{{ not (unsafe_show_logs | bool) }}")))
    (task "VSphere CSI Driver | Apply a CSI secret manifest"
      (command 
        (cmd (jinja "{{ kubectl }}") " apply -f -")
        (stdin (jinja "{{ vsphere_csi_secret_manifest.stdout }}")))
      (when "inventory_hostname == groups['kube_control_plane'][0]")
      (no_log (jinja "{{ not (unsafe_show_logs | bool) }}")))))
