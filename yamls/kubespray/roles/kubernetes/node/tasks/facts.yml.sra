(playbook "kubespray/roles/kubernetes/node/tasks/facts.yml"
  (tasks
    (task "Gather cgroups facts for docker"
      (block (list
          
          (name "Look up docker cgroup driver")
          (shell "set -o pipefail && docker info | grep 'Cgroup Driver' | awk -F': ' '{ print $2; }'")
          (args 
            (executable "/bin/bash"))
          (register "docker_cgroup_driver_result")
          (changed_when "false")
          (check_mode "false")
          
          (name "Set kubelet_cgroup_driver_detected fact for docker")
          (set_fact 
            (kubelet_cgroup_driver_detected (jinja "{{ docker_cgroup_driver_result.stdout }}")))))
      (when "container_manager == 'docker'"))
    (task "Gather cgroups facts for crio"
      (block (list
          
          (name "Look up crio cgroup driver")
          (shell "set -o pipefail && " (jinja "{{ bin_dir }}") "/" (jinja "{{ crio_status_command }}") " info | grep 'cgroup driver' | awk -F': ' '{ print $2; }'")
          (args 
            (executable "/bin/bash"))
          (register "crio_cgroup_driver_result")
          (changed_when "false")
          
          (name "Set kubelet_cgroup_driver_detected fact for crio")
          (set_fact 
            (kubelet_cgroup_driver_detected (jinja "{{ crio_cgroup_driver_result.stdout }}")))))
      (when "container_manager == 'crio'"))
    (task "Set kubelet_cgroup_driver_detected fact for containerd"
      (set_fact 
        (kubelet_cgroup_driver_detected (jinja "{%- if containerd_use_systemd_cgroup -%}") "systemd" (jinja "{%- else -%}") "cgroupfs" (jinja "{%- endif -%}")))
      (when "container_manager == 'containerd'"))
    (task "Set kubelet_cgroup_driver"
      (set_fact 
        (kubelet_cgroup_driver (jinja "{{ kubelet_cgroup_driver_detected }}")))
      (when "kubelet_cgroup_driver is undefined"))
    (task "Set kubelet_cgroups options when cgroupfs is used"
      (set_fact 
        (kubelet_runtime_cgroups (jinja "{{ kubelet_runtime_cgroups_cgroupfs }}"))
        (kubelet_kubelet_cgroups (jinja "{{ kubelet_kubelet_cgroups_cgroupfs }}")))
      (when "kubelet_cgroup_driver == 'cgroupfs'"))
    (task "Set kubelet_config_extra_args options when cgroupfs is used"
      (set_fact 
        (kubelet_config_extra_args (jinja "{{ kubelet_config_extra_args | combine(kubelet_config_extra_args_cgroupfs) }}")))
      (when "kubelet_cgroup_driver == 'cgroupfs'"))
    (task "Os specific vars"
      (include_vars (jinja "{{ item }}"))
      (with_first_found (list
          
          (files (list
              (jinja "{{ ansible_distribution | lower }}") "-" (jinja "{{ ansible_distribution_version | lower | replace('/', '_') }}") ".yml"
              (jinja "{{ ansible_distribution | lower }}") "-" (jinja "{{ ansible_distribution_release }}") ".yml"
              (jinja "{{ ansible_distribution | lower }}") "-" (jinja "{{ ansible_distribution_major_version | lower | replace('/', '_') }}") ".yml"
              (jinja "{{ ansible_distribution | lower }}") ".yml"
              (jinja "{{ ansible_os_family | lower }}") ".yml"))
          (skip "true"))))))
