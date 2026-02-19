(playbook "kubespray/roles/kubernetes-apps/argocd/tasks/main.yml"
  (tasks
    (task "Kubernetes Apps | Download yq"
      (include_tasks "../../../download/tasks/download_file.yml")
      (vars 
        (download (jinja "{{ download_defaults | combine(downloads.yq) }}"))))
    (task "Kubernetes Apps | Copy yq binary from download dir"
      (ansible.posix.synchronize 
        (src (jinja "{{ downloads.yq.dest }}"))
        (dest (jinja "{{ bin_dir }}") "/yq")
        (compress "false")
        (perms "true")
        (owner "false")
        (group "false"))
      (delegate_to (jinja "{{ inventory_hostname }}")))
    (task "Kubernetes Apps | Set ArgoCD template list"
      (set_fact 
        (argocd_templates (list
            
            (name "namespace")
            (file "argocd-namespace.yml")
            
            (name "install")
            (file (jinja "{{ downloads.argocd_install.dest | basename }}"))
            (namespace (jinja "{{ argocd_namespace }}"))
            (download (jinja "{{ downloads.argocd_install }}")))))
      (when (list
          "inventory_hostname == groups['kube_control_plane'][0]")))
    (task "Kubernetes Apps | Download ArgoCD remote manifests"
      (include_tasks "../../../download/tasks/download_file.yml")
      (vars 
        (download (jinja "{{ download_defaults | combine(item.download) }}")))
      (with_items (jinja "{{ argocd_templates | selectattr('download', 'defined') | list }}"))
      (loop_control 
        (label (jinja "{{ item.file }}")))
      (when (list
          "inventory_hostname == groups['kube_control_plane'][0]")))
    (task "Kubernetes Apps | Copy ArgoCD remote manifests from download dir"
      (ansible.posix.synchronize 
        (src (jinja "{{ local_release_dir }}") "/" (jinja "{{ item.file }}"))
        (dest (jinja "{{ kube_config_dir }}") "/" (jinja "{{ item.file }}"))
        (compress "false")
        (perms "true")
        (owner "false")
        (group "false"))
      (delegate_to (jinja "{{ inventory_hostname }}"))
      (with_items (jinja "{{ argocd_templates | selectattr('download', 'defined') | list }}"))
      (when (list
          "inventory_hostname == groups['kube_control_plane'][0]")))
    (task "Kubernetes Apps | Set ArgoCD namespace for remote manifests"
      (command (jinja "{{ bin_dir }}") "/yq eval-all -i '.metadata.namespace=\"" (jinja "{{ argocd_namespace }}") "\"' " (jinja "{{ kube_config_dir }}") "/" (jinja "{{ item.file }}") "
")
      (become "true")
      (with_items (jinja "{{ argocd_templates | selectattr('download', 'defined') | list }}"))
      (loop_control 
        (label (jinja "{{ item.file }}")))
      (when (list
          "inventory_hostname == groups['kube_control_plane'][0]")))
    (task "Kubernetes Apps | Create ArgoCD manifests from templates"
      (template 
        (src (jinja "{{ item.file }}") ".j2")
        (dest (jinja "{{ kube_config_dir }}") "/" (jinja "{{ item.file }}"))
        (mode "0644"))
      (become "true")
      (with_items (jinja "{{ argocd_templates | selectattr('download', 'undefined') | list }}"))
      (loop_control 
        (label (jinja "{{ item.file }}")))
      (when (list
          "inventory_hostname == groups['kube_control_plane'][0]")))
    (task "Kubernetes Apps | Install ArgoCD"
      (kube 
        (name "ArgoCD")
        (kubectl (jinja "{{ bin_dir }}") "/kubectl")
        (filename (jinja "{{ kube_config_dir }}") "/" (jinja "{{ item.file }}"))
        (state "latest"))
      (become "true")
      (with_items (jinja "{{ argocd_templates }}"))
      (when (list
          "inventory_hostname == groups['kube_control_plane'][0]")))
    (task "Kubernetes Apps | Set ArgoCD custom admin password"
      (shell (jinja "{{ bin_dir }}") "/kubectl --kubeconfig /etc/kubernetes/admin.conf -n " (jinja "{{ argocd_namespace }}") " patch secret argocd-secret -p \\
  '{
    \"stringData\": {
      \"admin.password\": \"" (jinja "{{ argocd_admin_password | password_hash('bcrypt') }}") "\",
      \"admin.passwordMtime\": \"'$(date +%FT%T%Z)'\"
    }
  }'
")
      (become "true")
      (when (list
          "argocd_admin_password is defined"
          "inventory_hostname == groups['kube_control_plane'][0]")))))
