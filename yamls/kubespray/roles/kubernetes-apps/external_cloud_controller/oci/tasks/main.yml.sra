(playbook "kubespray/roles/kubernetes-apps/external_cloud_controller/oci/tasks/main.yml"
  (tasks
    (task "External OCI Cloud Controller Manager | Check credentials"
      (ansible.builtin.assert 
        (that (list
            "external_oracle_auth_key | length > 0"
            "external_oracle_auth_region | length > 0"
            "external_oracle_auth_tenancy | length > 0"
            "external_oracle_auth_user | length > 0"
            "external_oracle_auth_fingerprint | length > 0")))
      (when "not external_oracle_auth_use_instance_principals"))
    (task "External OCI Cloud Controller Manager | Check settings"
      (ansible.builtin.assert 
        (that (list
            "external_oracle_compartment | length > 0"
            "external_oracle_vcn | length > 0"
            "external_oracle_load_balancer_subnet1 | length > 0"
            "external_oracle_load_balancer_subnet2 | length > 0"
            "external_oracle_load_balancer_security_list_management_mode in [\"All\", \"Frontend\", \"None\"]"))))
    (task "External OCI Cloud Controller Manager | Get base64 cloud-config"
      (set_fact 
        (external_oracle_cloud_config_secret (jinja "{{ lookup('template', 'external-oci-cloud-config.j2') | b64encode }}")))
      (when "inventory_hostname == groups['kube_control_plane'][0]")
      (tags "external-oci"))
    (task "External OCI Cloud Controller Manager | Generate Manifests"
      (template 
        (src (jinja "{{ item.file }}") ".j2")
        (dest (jinja "{{ kube_config_dir }}") "/" (jinja "{{ item.file }}"))
        (group (jinja "{{ kube_cert_group }}"))
        (mode "0640"))
      (with_items (list
          
          (name "external-oci-cloud-config-secret")
          (file "external-oci-cloud-config-secret.yml")
          
          (name "external-oci-cloud-controller-manager-rbac")
          (file "external-oci-cloud-controller-manager-rbac.yml")
          
          (name "external-oci-cloud-controller-manager")
          (file "external-oci-cloud-controller-manager.yml")))
      (register "external_oracle_manifests")
      (when "inventory_hostname == groups['kube_control_plane'][0]")
      (tags "external-oci"))
    (task "External OCI Cloud Controller Manager | Apply Manifests"
      (kube 
        (kubectl (jinja "{{ bin_dir }}") "/kubectl")
        (filename (jinja "{{ kube_config_dir }}") "/" (jinja "{{ item.item.file }}"))
        (state "latest"))
      (with_items (list
          (jinja "{{ external_oracle_manifests.results }}")))
      (when (list
          "inventory_hostname == groups['kube_control_plane'][0]"
          "not item is skipped"))
      (loop_control 
        (label (jinja "{{ item.item.file }}")))
      (tags "external-oci"))))
