(playbook "kubespray/roles/container-engine/tasks/main.yml"
  (tasks
    (task "Validate container engine"
      (import_role 
        (name "container-engine/validate-container-engine"))
      (tags (list
          "container-engine"
          "validate-container-engine")))
    (task "Container runtimes"
      (include_role 
        (name "container-engine/" (jinja "{{ item.role }}"))
        (apply 
          (tags (list
              "container-engine"
              (jinja "{{ item.role }}")))))
      (loop (list
          
          (role "kata-containers")
          (enabled (jinja "{{ kata_containers_enabled }}"))
          
          (role "gvisor")
          (enabled (jinja "{{ gvisor_enabled and container_manager in ['docker', 'containerd'] }}"))
          
          (role "crun")
          (enabled (jinja "{{ crun_enabled }}"))
          
          (role "youki")
          (enabled (jinja "{{ youki_enabled and container_manager == 'crio' }}"))))
      (when "item.enabled")
      (tags (list
          "container-engine"
          "kata-containers"
          "gvisor"
          "crun"
          "youki")))
    (task "Container Manager"
      (include_role 
        (name "container-engine/" (jinja "{{ container_manager_role[container_manager] }}"))
        (apply 
          (tags (list
              "container-engine"
              "crio"
              "docker"
              "containerd"))))
      (vars 
        (container_manager_role 
          (crio "cri-o")
          (docker "cri-dockerd")
          (containerd "containerd")))
      (tags (list
          "container-engine"
          "crio"
          "docker"
          "containerd")))))
