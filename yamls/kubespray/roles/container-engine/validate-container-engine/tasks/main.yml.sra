(playbook "kubespray/roles/container-engine/validate-container-engine/tasks/main.yml"
  (tasks
    (task "Validate-container-engine | check if fedora coreos"
      (stat 
        (path "/run/ostree-booted")
        (get_attributes "false")
        (get_checksum "false")
        (get_mime "false"))
      (register "ostree")
      (tags (list
          "facts")))
    (task "Validate-container-engine | set is_ostree"
      (set_fact 
        (is_ostree (jinja "{{ ostree.stat.exists }}")))
      (tags (list
          "facts")))
    (task "Ensure kubelet systemd unit exists"
      (stat 
        (path "/etc/systemd/system/kubelet.service"))
      (register "kubelet_systemd_unit_exists")
      (tags (list
          "facts")))
    (task "Populate service facts"
      (service_facts null)
      (tags (list
          "facts")))
    (task "Check if containerd is installed"
      (find 
        (file_type "file")
        (recurse "true")
        (use_regex "true")
        (patterns (list
            "containerd.service$"))
        (paths (list
            "/lib/systemd"
            "/etc/systemd"
            "/run/systemd")))
      (register "containerd_installed")
      (tags (list
          "facts")))
    (task "Check if docker is installed"
      (find 
        (file_type "file")
        (recurse "true")
        (use_regex "true")
        (patterns (list
            "docker.service$"))
        (paths (list
            "/lib/systemd"
            "/etc/systemd"
            "/run/systemd")))
      (register "docker_installed")
      (tags (list
          "facts")))
    (task "Check if crio is installed"
      (find 
        (file_type "file")
        (recurse "true")
        (use_regex "true")
        (patterns (list
            "crio.service$"))
        (paths (list
            "/lib/systemd"
            "/etc/systemd"
            "/run/systemd")))
      (register "crio_installed")
      (tags (list
          "facts")))
    (task "Uninstall containerd"
      (block (list
          
          (name "Drain node")
          (include_role 
            (name "remove_node/pre_remove")
            (apply 
              (tags (list
                  "pre-remove"))))
          (when "kubelet_systemd_unit_exists.stat.exists")
          
          (name "Stop kubelet")
          (service 
            (name "kubelet")
            (state "stopped"))
          (when "kubelet_systemd_unit_exists.stat.exists")
          
          (name "Remove Containerd")
          (import_role 
            (name "container-engine/containerd")
            (tasks_from "reset")
            (handlers_from "reset"))))
      (vars 
        (service_name "containerd.service"))
      (when (list
          "not (is_ostree or (ansible_distribution == \"Flatcar Container Linux by Kinvolk\") or (ansible_distribution == \"Flatcar\"))"
          "container_manager != \"containerd\""
          "docker_installed.matched == 0"
          "containerd_installed.matched > 0"
          "ansible_facts.services[service_name]['state'] == 'running'")))
    (task "Uninstall docker"
      (block (list
          
          (name "Drain node")
          (include_role 
            (name "remove_node/pre_remove")
            (apply 
              (tags (list
                  "pre-remove"))))
          (when "kubelet_systemd_unit_exists.stat.exists")
          
          (name "Stop kubelet")
          (service 
            (name "kubelet")
            (state "stopped"))
          (when "kubelet_systemd_unit_exists.stat.exists")
          
          (name "Remove Docker")
          (import_role 
            (name "container-engine/docker")
            (tasks_from "reset"))))
      (vars 
        (service_name "docker.service"))
      (when (list
          "not (is_ostree or (ansible_distribution == \"Flatcar Container Linux by Kinvolk\") or (ansible_distribution == \"Flatcar\"))"
          "container_manager != \"docker\""
          "docker_installed.matched > 0"
          "ansible_facts.services[service_name]['state'] == 'running'")))
    (task "Uninstall crio"
      (block (list
          
          (name "Drain node")
          (include_role 
            (name "remove_node/pre_remove")
            (apply 
              (tags (list
                  "pre-remove"))))
          (when "kubelet_systemd_unit_exists.stat.exists")
          
          (name "Stop kubelet")
          (service 
            (name "kubelet")
            (state "stopped"))
          (when "kubelet_systemd_unit_exists.stat.exists")
          
          (name "Remove CRI-O")
          (import_role 
            (name "container-engine/cri-o")
            (tasks_from "reset"))))
      (vars 
        (service_name "crio.service"))
      (when (list
          "not (is_ostree or (ansible_distribution == \"Flatcar Container Linux by Kinvolk\") or (ansible_distribution == \"Flatcar\"))"
          "container_manager != \"crio\""
          "crio_installed.matched > 0"
          "ansible_facts.services[service_name]['state'] == 'running'")))))
