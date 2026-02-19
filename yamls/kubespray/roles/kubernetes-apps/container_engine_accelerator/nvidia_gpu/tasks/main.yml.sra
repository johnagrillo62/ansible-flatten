(playbook "kubespray/roles/kubernetes-apps/container_engine_accelerator/nvidia_gpu/tasks/main.yml"
  (tasks
    (task "Container Engine Acceleration Nvidia GPU | gather os specific variables"
      (include_vars (jinja "{{ item }}"))
      (with_first_found (list
          
          (files (list
              (jinja "{{ ansible_distribution | lower }}") "-" (jinja "{{ ansible_distribution_version | lower | replace('/', '_') }}") ".yml"
              (jinja "{{ ansible_distribution | lower }}") "-" (jinja "{{ ansible_distribution_release }}") ".yml"
              (jinja "{{ ansible_distribution | lower }}") "-" (jinja "{{ ansible_distribution_major_version | lower | replace('/', '_') }}") ".yml"
              (jinja "{{ ansible_distribution | lower }}") ".yml"
              (jinja "{{ ansible_os_family | lower }}") ".yml"))
          (skip "true"))))
    (task "Container Engine Acceleration Nvidia GPU | Set fact of download url Tesla"
      (set_fact 
        (nvidia_driver_download_url_default (jinja "{{ nvidia_gpu_tesla_base_url }}") (jinja "{{ nvidia_url_end }}")))
      (when "nvidia_gpu_flavor | lower == \"tesla\""))
    (task "Container Engine Acceleration Nvidia GPU | Set fact of download url GTX"
      (set_fact 
        (nvidia_driver_download_url_default (jinja "{{ nvidia_gpu_gtx_base_url }}") (jinja "{{ nvidia_url_end }}")))
      (when "nvidia_gpu_flavor | lower == \"gtx\""))
    (task "Container Engine Acceleration Nvidia GPU | Create addon dir"
      (file 
        (path (jinja "{{ kube_config_dir }}") "/addons/container_engine_accelerator")
        (owner "root")
        (group "root")
        (mode "0755")
        (recurse "true")))
    (task "Container Engine Acceleration Nvidia GPU | Create manifests for nvidia accelerators"
      (template 
        (src (jinja "{{ item.file }}") ".j2")
        (dest (jinja "{{ kube_config_dir }}") "/addons/container_engine_accelerator/" (jinja "{{ item.file }}"))
        (mode "0644"))
      (with_items (list
          
          (name "nvidia-driver-install-daemonset")
          (file "nvidia-driver-install-daemonset.yml")
          (type "daemonset")
          
          (name "k8s-device-plugin-nvidia-daemonset")
          (file "k8s-device-plugin-nvidia-daemonset.yml")
          (type "daemonset")))
      (register "container_engine_accelerator_manifests")
      (when (list
          "inventory_hostname == groups['kube_control_plane'][0] and nvidia_driver_install_container")))
    (task "Container Engine Acceleration Nvidia GPU | Apply manifests for nvidia accelerators"
      (kube 
        (name (jinja "{{ item.item.name }}"))
        (namespace "kube-system")
        (kubectl (jinja "{{ bin_dir }}") "/kubectl")
        (resource (jinja "{{ item.item.type }}"))
        (filename (jinja "{{ kube_config_dir }}") "/addons/container_engine_accelerator/" (jinja "{{ item.item.file }}"))
        (state "latest"))
      (with_items (list
          (jinja "{{ container_engine_accelerator_manifests.results }}")))
      (when (list
          "inventory_hostname == groups['kube_control_plane'][0] and nvidia_driver_install_container and nvidia_driver_install_supported")))))
