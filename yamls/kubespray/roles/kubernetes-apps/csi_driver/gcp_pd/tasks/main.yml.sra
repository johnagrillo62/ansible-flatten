(playbook "kubespray/roles/kubernetes-apps/csi_driver/gcp_pd/tasks/main.yml"
  (tasks
    (task "GCP PD CSI Driver | Check if cloud-sa.json exists"
      (fail 
        (msg "Credentials file cloud-sa.json is mandatory"))
      (when "gcp_pd_csi_sa_cred_file is not defined or not gcp_pd_csi_sa_cred_file"))
    (task "GCP PD CSI Driver | Copy GCP credentials file"
      (copy 
        (src (jinja "{{ gcp_pd_csi_sa_cred_file }}"))
        (dest (jinja "{{ kube_config_dir }}") "/cloud-sa.json")
        (group (jinja "{{ kube_cert_group }}"))
        (mode "0640"))
      (when "inventory_hostname == groups['kube_control_plane'][0]"))
    (task "GCP PD CSI Driver | Get base64 cloud-sa.json"
      (slurp 
        (src (jinja "{{ kube_config_dir }}") "/cloud-sa.json"))
      (register "gcp_cred_secret")
      (when "inventory_hostname == groups['kube_control_plane'][0]"))
    (task "GCP PD CSI Driver | Generate Manifests"
      (template 
        (src (jinja "{{ item.file }}") ".j2")
        (dest (jinja "{{ kube_config_dir }}") "/" (jinja "{{ item.file }}"))
        (mode "0644"))
      (with_items (list
          
          (name "gcp-pd-csi-cred-secret")
          (file "gcp-pd-csi-cred-secret.yml")
          
          (name "gcp-pd-csi-setup")
          (file "gcp-pd-csi-setup.yml")
          
          (name "gcp-pd-csi-controller")
          (file "gcp-pd-csi-controller.yml")
          
          (name "gcp-pd-csi-node")
          (file "gcp-pd-csi-node.yml")
          
          (name "gcp-pd-csi-sc-regional")
          (file "gcp-pd-csi-sc-regional.yml")
          
          (name "gcp-pd-csi-sc-zonal")
          (file "gcp-pd-csi-sc-zonal.yml")))
      (register "gcp_pd_csi_manifests")
      (when "inventory_hostname == groups['kube_control_plane'][0]"))
    (task "GCP PD CSI Driver | Apply Manifests"
      (kube 
        (kubectl (jinja "{{ bin_dir }}") "/kubectl")
        (filename (jinja "{{ kube_config_dir }}") "/" (jinja "{{ item.item.file }}"))
        (state "latest"))
      (with_items (list
          (jinja "{{ gcp_pd_csi_manifests.results }}")))
      (when (list
          "inventory_hostname == groups['kube_control_plane'][0]"
          "not item is skipped"))
      (loop_control 
        (label (jinja "{{ item.item.file }}"))))))
