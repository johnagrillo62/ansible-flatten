(playbook "kubespray/roles/kubernetes-apps/external_cloud_controller/openstack/tasks/main.yml"
  (tasks
    (task "External OpenStack Cloud Controller | Check OpenStack credentials"
      (include_tasks "openstack-credential-check.yml")
      (tags "external-openstack"))
    (task "External OpenStack Cloud Controller | Get base64 cacert"
      (slurp 
        (src (jinja "{{ external_openstack_cacert }}")))
      (register "external_openstack_cacert_b64")
      (when (list
          "inventory_hostname == groups['kube_control_plane'][0]"
          "external_openstack_cacert is defined"
          "external_openstack_cacert | length > 0"))
      (tags "external-openstack"))
    (task "External OpenStack Cloud Controller | Get base64 cloud-config"
      (set_fact 
        (external_openstack_cloud_config_secret (jinja "{{ lookup('template', 'external-openstack-cloud-config.j2') | b64encode }}")))
      (when "inventory_hostname == groups['kube_control_plane'][0]")
      (tags "external-openstack"))
    (task "External OpenStack Cloud Controller | Generate Manifests"
      (template 
        (src (jinja "{{ item.file }}") ".j2")
        (dest (jinja "{{ kube_config_dir }}") "/" (jinja "{{ item.file }}"))
        (group (jinja "{{ kube_cert_group }}"))
        (mode "0640"))
      (with_items (list
          
          (name "external-openstack-cloud-config-secret")
          (file "external-openstack-cloud-config-secret.yml")
          
          (name "external-openstack-cloud-controller-manager-roles")
          (file "external-openstack-cloud-controller-manager-roles.yml")
          
          (name "external-openstack-cloud-controller-manager-role-bindings")
          (file "external-openstack-cloud-controller-manager-role-bindings.yml")
          
          (name "external-openstack-cloud-controller-manager-ds")
          (file "external-openstack-cloud-controller-manager-ds.yml")))
      (register "external_openstack_manifests")
      (when "inventory_hostname == groups['kube_control_plane'][0]")
      (tags "external-openstack"))
    (task "External OpenStack Cloud Controller | Apply Manifests"
      (kube 
        (kubectl (jinja "{{ bin_dir }}") "/kubectl")
        (filename (jinja "{{ kube_config_dir }}") "/" (jinja "{{ item.item.file }}"))
        (state "latest"))
      (with_items (list
          (jinja "{{ external_openstack_manifests.results }}")))
      (when (list
          "inventory_hostname == groups['kube_control_plane'][0]"
          "not item is skipped"))
      (loop_control 
        (label (jinja "{{ item.item.file }}")))
      (tags "external-openstack"))))
