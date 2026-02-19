(playbook "kubespray/roles/kubernetes-apps/ingress_controller/alb_ingress_controller/tasks/main.yml"
  (tasks
    (task "ALB Ingress Controller | Create addon dir"
      (file 
        (path (jinja "{{ kube_config_dir }}") "/addons/alb_ingress")
        (state "directory")
        (owner "root")
        (group "root")
        (mode "0755")))
    (task "ALB Ingress Controller | Create manifests"
      (template 
        (src (jinja "{{ item.file }}") ".j2")
        (dest (jinja "{{ kube_config_dir }}") "/addons/alb_ingress/" (jinja "{{ item.file }}"))
        (mode "0644"))
      (with_items (list
          
          (name "alb-ingress-clusterrole")
          (file "alb-ingress-clusterrole.yml")
          (type "clusterrole")
          
          (name "alb-ingress-clusterrolebinding")
          (file "alb-ingress-clusterrolebinding.yml")
          (type "clusterrolebinding")
          
          (name "alb-ingress-ns")
          (file "alb-ingress-ns.yml")
          (type "ns")
          
          (name "alb-ingress-sa")
          (file "alb-ingress-sa.yml")
          (type "sa")
          
          (name "alb-ingress-deploy")
          (file "alb-ingress-deploy.yml")
          (type "deploy")))
      (register "alb_ingress_manifests")
      (when (list
          "inventory_hostname == groups['kube_control_plane'][0]")))
    (task "ALB Ingress Controller | Apply manifests"
      (kube 
        (name (jinja "{{ item.item.name }}"))
        (namespace (jinja "{{ alb_ingress_controller_namespace }}"))
        (kubectl (jinja "{{ bin_dir }}") "/kubectl")
        (resource (jinja "{{ item.item.type }}"))
        (filename (jinja "{{ kube_config_dir }}") "/addons/alb_ingress/" (jinja "{{ item.item.file }}"))
        (state "latest"))
      (with_items (jinja "{{ alb_ingress_manifests.results }}"))
      (when (list
          "inventory_hostname == groups['kube_control_plane'][0]")))))
