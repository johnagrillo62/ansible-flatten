(playbook "kubespray/roles/kubernetes-apps/container_runtimes/gvisor/tasks/main.yaml"
  (tasks
    (task "GVisor | Create addon dir"
      (file 
        (path (jinja "{{ kube_config_dir }}") "/addons/gvisor")
        (owner "root")
        (group "root")
        (mode "0755")
        (recurse "true")))
    (task "GVisor | Templates List"
      (set_fact 
        (gvisor_templates (list
            
            (name "runtimeclass-gvisor")
            (file "runtimeclass-gvisor.yml")
            (type "runtimeclass")))))
    (task "GVisort | Create manifests"
      (template 
        (src (jinja "{{ item.file }}") ".j2")
        (dest (jinja "{{ kube_config_dir }}") "/addons/gvisor/" (jinja "{{ item.file }}"))
        (mode "0644"))
      (with_items (jinja "{{ gvisor_templates }}"))
      (register "gvisor_manifests")
      (when (list
          "inventory_hostname == groups['kube_control_plane'][0]")))
    (task "GVisor | Apply manifests"
      (kube 
        (name (jinja "{{ item.item.name }}"))
        (kubectl (jinja "{{ bin_dir }}") "/kubectl")
        (resource (jinja "{{ item.item.type }}"))
        (filename (jinja "{{ kube_config_dir }}") "/addons/gvisor/" (jinja "{{ item.item.file }}"))
        (state "latest"))
      (with_items (jinja "{{ gvisor_manifests.results }}"))
      (when (list
          "inventory_hostname == groups['kube_control_plane'][0]")))))
