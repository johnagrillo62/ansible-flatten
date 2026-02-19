(playbook "kubespray/roles/kubernetes-apps/kubelet-csr-approver/meta/main.yml"
  (dependencies (list
      
      (role "helm-apps")
      (when (list
          "inventory_hostname == groups['kube_control_plane'][0]"
          "kubelet_csr_approver_enabled"))
      (environment 
        (http_proxy (jinja "{{ http_proxy | default('') }}"))
        (https_proxy (jinja "{{ https_proxy | default('') }}")))
      (release_common_opts )
      (releases (list
          
          (name "kubelet-csr-approver")
          (namespace (jinja "{{ kubelet_csr_approver_namespace }}"))
          (chart_ref (jinja "{{ kubelet_csr_approver_chart_ref }}"))
          (chart_version (jinja "{{ kubelet_csr_approver_chart_version }}"))
          (wait (jinja "{{ kube_network_plugin != 'cni' }}"))
          (atomic (jinja "{{ kube_network_plugin != 'cni' }}"))
          (values (jinja "{{ kubelet_csr_approver_values }}"))))
      (repositories (list
          
          (name (jinja "{{ kubelet_csr_approver_repository_name }}"))
          (url (jinja "{{ kubelet_csr_approver_repository_url }}")))))))
