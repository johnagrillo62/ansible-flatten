(playbook "kubespray/roles/kubernetes-apps/container_runtimes/youki/tasks/main.yaml"
  (tasks
    (task "Youki | Copy runtime class manifest"
      (template 
        (src "runtimeclass-youki.yml")
        (dest (jinja "{{ kube_config_dir }}") "/runtimeclass-youki.yml")
        (mode "0664"))
      (when (list
          "inventory_hostname == groups['kube_control_plane'][0]")))
    (task "Youki | Apply manifests"
      (kube 
        (name "runtimeclass-youki")
        (kubectl (jinja "{{ bin_dir }}") "/kubectl")
        (resource "runtimeclass")
        (filename (jinja "{{ kube_config_dir }}") "/runtimeclass-youki.yml")
        (state "latest"))
      (when (list
          "inventory_hostname == groups['kube_control_plane'][0]")))))
