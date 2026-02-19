(playbook "kubespray/roles/container-engine/containerd/defaults/main.yml"
  (containerd_storage_dir "/var/lib/containerd")
  (containerd_state_dir "/run/containerd")
  (containerd_systemd_dir "/etc/systemd/system/containerd.service.d")
  (containerd_oom_score "0")
  (containerd_default_runtime "runc")
  (containerd_snapshotter "overlayfs")
  (containerd_runc_runtime 
    (name "runc")
    (type "io.containerd.runc.v2")
    (base_runtime_spec "cri-base.json")
    (options 
      (Root "")
      (SystemdCgroup (jinja "{{ containerd_use_systemd_cgroup | ternary('true', 'false') }}"))
      (BinaryName (jinja "{{ bin_dir }}") "/runc")))
  (containerd_additional_runtimes (list))
  (containerd_base_runtime_spec_rlimit_nofile "65535")
  (containerd_default_base_runtime_spec_patch 
    (process 
      (rlimits (list
          
          (type "RLIMIT_NOFILE")
          (hard (jinja "{{ containerd_base_runtime_spec_rlimit_nofile }}"))
          (soft (jinja "{{ containerd_base_runtime_spec_rlimit_nofile }}"))))))
  (containerd_discard_unpacked_layers "true")
  (containerd_base_runtime_specs 
    (cri-base.json (jinja "{{ containerd_default_base_runtime_spec | combine(containerd_default_base_runtime_spec_patch, recursive=1) }}")))
  (containerd_grpc_max_recv_message_size "16777216")
  (containerd_grpc_max_send_message_size "16777216")
  (containerd_debug_address "")
  (containerd_debug_level "info")
  (containerd_debug_format "")
  (containerd_debug_uid "0")
  (containerd_debug_gid "0")
  (containerd_metrics_address "")
  (containerd_metrics_grpc_histogram "false")
  (containerd_registries_mirrors (list
      
      (prefix "docker.io")
      (mirrors (list
          
          (host "https://registry-1.docker.io")
          (capabilities (list
              "pull"
              "resolve"))
          (skip_verify "false")))))
  (containerd_max_container_log_line_size "16384")
  (containerd_enable_unprivileged_ports "false")
  (containerd_enable_unprivileged_icmp "false")
  (containerd_enable_selinux "false")
  (containerd_disable_apparmor "false")
  (containerd_tolerate_missing_hugetlb_controller "true")
  (containerd_disable_hugetlb_controller "true")
  (containerd_image_pull_progress_timeout "5m")
  (containerd_cfg_dir "/etc/containerd")
  (containerd_extra_args "")
  (containerd_extra_runtime_args )
  (containerd_registry_auth (list))
  (containerd_limit_proc_num "infinity")
  (containerd_limit_core "infinity")
  (containerd_limit_open_file_num "1048576")
  (containerd_limit_mem_lock "infinity")
  (containerd_supported_distributions (list
      "CentOS"
      "OracleLinux"
      "RedHat"
      "Ubuntu"
      "Debian"
      "Fedora"
      "AlmaLinux"
      "Rocky"
      "Amazon"
      "Flatcar"
      "Flatcar Container Linux by Kinvolk"
      "Suse"
      "openSUSE Leap"
      "openSUSE Tumbleweed"
      "Kylin Linux Advanced Server"
      "UnionTech"
      "UniontechOS"
      "openEuler"))
  (enable_cdi "false")
  (containerd_tracing_enabled "false")
  (containerd_tracing_endpoint "[::]:4317")
  (containerd_tracing_protocol "grpc")
  (containerd_tracing_sampling_ratio "1.0")
  (containerd_tracing_service_name "containerd"))
