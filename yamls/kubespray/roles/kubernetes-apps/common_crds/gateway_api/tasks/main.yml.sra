(playbook "kubespray/roles/kubernetes-apps/common_crds/gateway_api/tasks/main.yml"
  (tasks
    (task "Gateway API | Download YAML"
      (include_tasks "../../../../download/tasks/download_file.yml")
      (vars 
        (download (jinja "{{ download_defaults | combine(downloads.gateway_api_crds) }}"))))
    (task "Gateway API | Create addon dir"
      (file 
        (path (jinja "{{ kube_config_dir }}") "/addons/gateway_api")
        (state "directory")
        (owner "root")
        (group "root")
        (mode "0755"))
      (when (list
          "inventory_hostname == groups['kube_control_plane'][0]")))
    (task "Gateway API | Copy YAML from download dir"
      (copy 
        (src (jinja "{{ local_release_dir }}") "/gateway-api-" (jinja "{{ gateway_api_channel }}") "-install.yaml")
        (dest (jinja "{{ kube_config_dir }}") "/addons/gateway_api/" (jinja "{{ gateway_api_channel }}") "-install.yaml")
        (mode "0644")
        (remote_src "true"))
      (when (list
          "inventory_hostname == groups['kube_control_plane'][0]")))
    (task "Gateway API | Install Gateway API"
      (kube 
        (name "Gateway API")
        (kubectl (jinja "{{ bin_dir }}") "/kubectl")
        (filename (jinja "{{ kube_config_dir }}") "/addons/gateway_api/" (jinja "{{ gateway_api_channel }}") "-install.yaml")
        (state "latest"))
      (when (list
          "inventory_hostname == groups['kube_control_plane'][0]")))))
