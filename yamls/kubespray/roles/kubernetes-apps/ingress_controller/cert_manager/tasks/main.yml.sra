(playbook "kubespray/roles/kubernetes-apps/ingress_controller/cert_manager/tasks/main.yml"
  (tasks
    (task "Cert Manager | Remove legacy addon dir and manifests"
      (file 
        (path (jinja "{{ kube_config_dir }}") "/addons/cert_manager")
        (state "absent"))
      (when (list
          "inventory_hostname == groups['kube_control_plane'][0]"))
      (tags (list
          "upgrade")))
    (task "Cert Manager | Remove legacy namespace"
      (command (jinja "{{ kubectl }}") " delete namespace " (jinja "{{ cert_manager_namespace }}") "
")
      (ignore_errors "true")
      (when (list
          "inventory_hostname == groups['kube_control_plane'][0]"))
      (tags (list
          "upgrade")))
    (task "Cert Manager | Create addon dir"
      (file 
        (path (jinja "{{ kube_config_dir }}") "/addons/cert_manager")
        (state "directory")
        (owner "root")
        (group "root")
        (mode "0755"))
      (when (list
          "inventory_hostname == groups['kube_control_plane'][0]")))
    (task "Cert Manager | Templates list"
      (set_fact 
        (cert_manager_templates (list
            
            (name "cert-manager")
            (file "cert-manager.yml")
            (type "all")
            
            (name "cert-manager.crds")
            (file "cert-manager.crds.yml")
            (type "crd")))))
    (task "Cert Manager | Create manifests"
      (template 
        (src (jinja "{{ item.file }}") ".j2")
        (dest (jinja "{{ kube_config_dir }}") "/addons/cert_manager/" (jinja "{{ item.file }}"))
        (mode "0644"))
      (with_items (jinja "{{ cert_manager_templates }}"))
      (register "cert_manager_manifests")
      (when (list
          "inventory_hostname == groups['kube_control_plane'][0]")))
    (task "Cert Manager | Apply manifests"
      (kube 
        (name (jinja "{{ item.item.name }}"))
        (kubectl (jinja "{{ bin_dir }}") "/kubectl")
        (resource (jinja "{{ item.item.type }}"))
        (filename (jinja "{{ kube_config_dir }}") "/addons/cert_manager/" (jinja "{{ item.item.file }}"))
        (state "latest"))
      (with_items (jinja "{{ cert_manager_manifests.results }}"))
      (when (list
          "inventory_hostname == groups['kube_control_plane'][0]")))))
