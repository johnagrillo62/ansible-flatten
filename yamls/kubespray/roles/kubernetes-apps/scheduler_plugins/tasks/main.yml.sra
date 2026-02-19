(playbook "kubespray/roles/kubernetes-apps/scheduler_plugins/tasks/main.yml"
  (tasks
    (task "Scheduler Plugins | Ensure dir exists"
      (file 
        (path (jinja "{{ kube_config_dir }}") "/scheduler-plugins")
        (state "directory")
        (owner "root")
        (group "root")
        (mode "0755"))
      (when "inventory_hostname == groups['kube_control_plane'][0]")
      (tags (list
          "scheduler_plugins")))
    (task "Scheduler Plugins | Create manifests"
      (template 
        (src (jinja "{{ item.file }}") ".j2")
        (dest (jinja "{{ kube_config_dir }}") "/scheduler-plugins/" (jinja "{{ item.file }}"))
        (mode "0644"))
      (with_items (list
          
          (name "appgroup")
          (file "appgroup.diktyo.x-k8s.io_appgroups.yaml")
          (type "crd")
          
          (name "networktopology")
          (file "networktopology.diktyo.x-k8s.io_networktopologies.yaml")
          (type "crd")
          
          (name "elasticquotas")
          (file "scheduling.x-k8s.io_elasticquotas.yaml")
          (type "crd")
          
          (name "podgroups")
          (file "scheduling.x-k8s.io_podgroups.yaml")
          (type "crd")
          
          (name "noderesourcetopologies")
          (file "topology.node.k8s.io_noderesourcetopologies.yaml")
          (type "crd")
          
          (name "namespace")
          (file "namespace.yaml")
          (type "namespace")
          
          (name "sa")
          (file "sa-scheduler-plugins.yaml")
          (type "serviceaccount")
          
          (name "rbac")
          (file "rbac-scheduler-plugins.yaml")
          (type "rbac")
          
          (name "cm")
          (file "cm-scheduler-plugins.yaml")
          (type "configmap")
          
          (name "deploy")
          (file "deploy-scheduler-plugins.yaml")
          (type "deployment")))
      (register "scheduler_plugins_manifests")
      (when "inventory_hostname == groups['kube_control_plane'][0]")
      (tags (list
          "scheduler_plugins")))
    (task "Scheduler Plugins | Apply manifests"
      (kube 
        (name (jinja "{{ item.item.name }}"))
        (kubectl (jinja "{{ bin_dir }}") "/kubectl")
        (resource (jinja "{{ item.item.type }}"))
        (filename (jinja "{{ kube_config_dir }}") "/scheduler-plugins/" (jinja "{{ item.item.file }}"))
        (state "latest"))
      (with_items (jinja "{{ scheduler_plugins_manifests.results }}"))
      (when "inventory_hostname == groups['kube_control_plane'][0]")
      (tags (list
          "scheduler_plugins")))
    (task "Scheduler Plugins | Wait for controller pods to be ready"
      (command (jinja "{{ kubectl }}") " -n " (jinja "{{ scheduler_plugins_namespace }}") " get pods -l app=scheduler-plugins-controller -o jsonpath='{.items[?(@.status.containerStatuses[0].ready==false)].metadata.name}'")
      (register "controller_pods_not_ready")
      (until "controller_pods_not_ready.stdout.find(\"scheduler-plugins-controller\")==-1")
      (retries "30")
      (delay "10")
      (ignore_errors "true")
      (changed_when "false")
      (when "inventory_hostname == groups['kube_control_plane'][0]")
      (tags (list
          "scheduler_plugins")))
    (task "Scheduler Plugins | Wait for scheduler pods to be ready"
      (command (jinja "{{ kubectl }}") " -n " (jinja "{{ scheduler_plugins_namespace }}") " get pods -l component=scheduler -o jsonpath='{.items[?(@.status.containerStatuses[0].ready==false)].metadata.name}'")
      (register "scheduler_pods_not_ready")
      (until "scheduler_pods_not_ready.stdout.find(\"scheduler-plugins-scheduler\")==-1")
      (retries "30")
      (delay "10")
      (ignore_errors "true")
      (changed_when "false")
      (when "inventory_hostname == groups['kube_control_plane'][0]")
      (tags (list
          "scheduler_plugins")))))
