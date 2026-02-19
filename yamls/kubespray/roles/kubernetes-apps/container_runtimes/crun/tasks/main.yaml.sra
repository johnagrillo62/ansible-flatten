(playbook "kubespray/roles/kubernetes-apps/container_runtimes/crun/tasks/main.yaml"
  (tasks
    (task "Crun | Copy runtime class manifest"
      (template 
        (src "runtimeclass-crun.yml")
        (dest (jinja "{{ kube_config_dir }}") "/runtimeclass-crun.yml")
        (mode "0664"))
      (when (list
          "inventory_hostname == groups['kube_control_plane'][0]")))
    (task "Crun | Apply manifests"
      (kube 
        (name "runtimeclass-crun")
        (kubectl (jinja "{{ bin_dir }}") "/kubectl")
        (resource "runtimeclass")
        (filename (jinja "{{ kube_config_dir }}") "/runtimeclass-crun.yml")
        (state "latest"))
      (when (list
          "inventory_hostname == groups['kube_control_plane'][0]")))))
