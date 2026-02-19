(playbook "kubespray/roles/kubernetes-apps/external_cloud_controller/huaweicloud/tasks/main.yml"
  (tasks
    (task "External Huawei Cloud Controller | Check Huawei credentials"
      (include_tasks "huaweicloud-credential-check.yml")
      (tags "external-huaweicloud"))
    (task "External huaweicloud Cloud Controller | Get base64 cacert"
      (slurp 
        (src (jinja "{{ external_huaweicloud_cacert }}")))
      (register "external_huaweicloud_cacert_b64")
      (when (list
          "inventory_hostname == groups['kube_control_plane'][0]"
          "external_huaweicloud_cacert is defined"
          "external_huaweicloud_cacert | length > 0"))
      (tags "external-huaweicloud"))
    (task "External huaweicloud Cloud Controller | Get base64 cloud-config"
      (set_fact 
        (external_huawei_cloud_config_secret (jinja "{{ lookup('template', 'external-huawei-cloud-config.j2') | b64encode }}")))
      (when "inventory_hostname == groups['kube_control_plane'][0]")
      (tags "external-huaweicloud"))
    (task "External Huawei Cloud Controller | Generate Manifests"
      (template 
        (src (jinja "{{ item.file }}") ".j2")
        (dest (jinja "{{ kube_config_dir }}") "/" (jinja "{{ item.file }}"))
        (group (jinja "{{ kube_cert_group }}"))
        (mode "0640"))
      (with_items (list
          
          (name "external-huawei-cloud-config-secret")
          (file "external-huawei-cloud-config-secret.yml")
          
          (name "external-huawei-cloud-controller-manager-roles")
          (file "external-huawei-cloud-controller-manager-roles.yml")
          
          (name "external-huawei-cloud-controller-manager-role-bindings")
          (file "external-huawei-cloud-controller-manager-role-bindings.yml")
          
          (name "external-huawei-cloud-controller-manager-ds")
          (file "external-huawei-cloud-controller-manager-ds.yml")))
      (register "external_huaweicloud_manifests")
      (when "inventory_hostname == groups['kube_control_plane'][0]")
      (tags "external-huaweicloud"))
    (task "External Huawei Cloud Controller | Apply Manifests"
      (kube 
        (kubectl (jinja "{{ bin_dir }}") "/kubectl")
        (filename (jinja "{{ kube_config_dir }}") "/" (jinja "{{ item.item.file }}"))
        (state "latest"))
      (with_items (list
          (jinja "{{ external_huaweicloud_manifests.results }}")))
      (when (list
          "inventory_hostname == groups['kube_control_plane'][0]"
          "not item is skipped"))
      (loop_control 
        (label (jinja "{{ item.item.file }}")))
      (tags "external-huaweicloud"))))
