(playbook "kubespray/roles/kubernetes-apps/external_cloud_controller/hcloud/tasks/main.yml"
  (tasks
    (task "External Hcloud Cloud Controller | Generate Manifests"
      (template 
        (src (jinja "{{ item.file }}") ".j2")
        (dest (jinja "{{ kube_config_dir }}") "/" (jinja "{{ item.file }}"))
        (group (jinja "{{ kube_cert_group }}"))
        (mode "0640"))
      (with_items (list
          
          (name "external-hcloud-cloud-secret")
          (file "external-hcloud-cloud-secret.yml")
          
          (name "external-hcloud-cloud-service-account")
          (file "external-hcloud-cloud-service-account.yml")
          
          (name "external-hcloud-cloud-role-bindings")
          (file "external-hcloud-cloud-role-bindings.yml")
          
          (name (jinja "{{ 'external-hcloud-cloud-controller-manager-ds-with-networks' if external_hcloud_cloud.with_networks else 'external-hcloud-cloud-controller-manager-ds' }}"))
          (file (jinja "{{ 'external-hcloud-cloud-controller-manager-ds-with-networks.yml' if external_hcloud_cloud.with_networks else 'external-hcloud-cloud-controller-manager-ds.yml' }}"))))
      (register "external_hcloud_manifests")
      (when "inventory_hostname == groups['kube_control_plane'][0]")
      (tags "external-hcloud"))
    (task "External Hcloud Cloud Controller | Apply Manifests"
      (kube 
        (kubectl (jinja "{{ bin_dir }}") "/kubectl")
        (filename (jinja "{{ kube_config_dir }}") "/" (jinja "{{ item.item.file }}"))
        (state "latest"))
      (with_items (list
          (jinja "{{ external_hcloud_manifests.results }}")))
      (when (list
          "inventory_hostname == groups['kube_control_plane'][0]"
          "not item is skipped"))
      (loop_control 
        (label (jinja "{{ item.item.file }}")))
      (tags "external-hcloud"))))
