(playbook "kubespray/roles/kubernetes-apps/container_runtimes/kata_containers/tasks/main.yaml"
  (tasks
    (task "Kata Containers | Create addon dir"
      (file 
        (path (jinja "{{ kube_config_dir }}") "/addons/kata_containers")
        (owner "root")
        (group "root")
        (mode "0755")
        (recurse "true")))
    (task "Kata Containers | Templates list"
      (set_fact 
        (kata_containers_templates (list
            
            (name "runtimeclass-kata-qemu")
            (file "runtimeclass-kata-qemu.yml")
            (type "runtimeclass")))))
    (task "Kata Containers | Create manifests"
      (template 
        (src (jinja "{{ item.file }}") ".j2")
        (dest (jinja "{{ kube_config_dir }}") "/addons/kata_containers/" (jinja "{{ item.file }}"))
        (mode "0644"))
      (with_items (jinja "{{ kata_containers_templates }}"))
      (register "kata_containers_manifests")
      (when (list
          "inventory_hostname == groups['kube_control_plane'][0]")))
    (task "Kata Containers | Apply manifests"
      (kube 
        (name (jinja "{{ item.item.name }}"))
        (kubectl (jinja "{{ bin_dir }}") "/kubectl")
        (resource (jinja "{{ item.item.type }}"))
        (filename (jinja "{{ kube_config_dir }}") "/addons/kata_containers/" (jinja "{{ item.item.file }}"))
        (state "latest"))
      (with_items (jinja "{{ kata_containers_manifests.results }}"))
      (when (list
          "inventory_hostname == groups['kube_control_plane'][0]")))))
