(playbook "kubespray/roles/kubernetes-apps/policy_controller/calico/tasks/main.yml"
  (tasks
    (task "Create calico-kube-controllers manifests"
      (template 
        (src (jinja "{{ item.file }}") ".j2")
        (dest (jinja "{{ kube_config_dir }}") "/" (jinja "{{ item.file }}"))
        (mode "0644"))
      (with_items (list
          
          (name "calico-kube-controllers")
          (file "calico-kube-controllers.yml")
          (type "deployment")
          
          (name "calico-kube-controllers")
          (file "calico-kube-sa.yml")
          (type "sa")
          
          (name "calico-kube-controllers")
          (file "calico-kube-cr.yml")
          (type "clusterrole")
          
          (name "calico-kube-controllers")
          (file "calico-kube-crb.yml")
          (type "clusterrolebinding")))
      (register "calico_kube_manifests")
      (when (list
          "inventory_hostname == groups['kube_control_plane'][0]"
          "rbac_enabled or item.type not in rbac_resources")))
    (task "Start of Calico kube controllers"
      (kube 
        (name (jinja "{{ item.item.name }}"))
        (namespace "kube-system")
        (kubectl (jinja "{{ bin_dir }}") "/kubectl")
        (resource (jinja "{{ item.item.type }}"))
        (filename (jinja "{{ kube_config_dir }}") "/" (jinja "{{ item.item.file }}"))
        (state "latest"))
      (with_items (list
          (jinja "{{ calico_kube_manifests.results }}")))
      (register "calico_kube_controller_start")
      (until "calico_kube_controller_start is succeeded")
      (retries "4")
      (when (list
          "inventory_hostname == groups['kube_control_plane'][0]"
          "not item is skipped"))
      (loop_control 
        (label (jinja "{{ item.item.file }}"))))))
