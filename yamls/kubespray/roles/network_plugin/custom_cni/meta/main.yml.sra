(playbook "kubespray/roles/network_plugin/custom_cni/meta/main.yml"
  (dependencies (list
      
      (role "helm-apps")
      (when (list
          "inventory_hostname == groups['kube_control_plane'][0]"
          "custom_cni_chart_release_name | length > 0"))
      (environment 
        (http_proxy (jinja "{{ http_proxy | default('') }}"))
        (https_proxy (jinja "{{ https_proxy | default('') }}")))
      (release_common_opts )
      (releases (list
          
          (name (jinja "{{ custom_cni_chart_release_name }}"))
          (namespace (jinja "{{ custom_cni_chart_namespace }}"))
          (chart_ref (jinja "{{ custom_cni_chart_ref }}"))
          (chart_version (jinja "{{ custom_cni_chart_version }}"))
          (wait "true")
          (values (jinja "{{ custom_cni_chart_values }}"))))
      (repositories (list
          
          (name (jinja "{{ custom_cni_chart_repository_name }}"))
          (url (jinja "{{ custom_cni_chart_repository_url }}")))))))
