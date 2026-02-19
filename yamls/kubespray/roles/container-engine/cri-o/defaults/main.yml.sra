(playbook "kubespray/roles/container-engine/cri-o/defaults/main.yml"
  (crio_cgroup_manager (jinja "{{ kubelet_cgroup_driver | default('systemd') }}"))
  (crio_conmon (jinja "{{ bin_dir }}") "/conmon")
  (crio_default_runtime "crun")
  (crio_libexec_dir "/usr/libexec/crio")
  (crio_runtime_switch "false")
  (crio_enable_metrics "false")
  (crio_log_level "info")
  (crio_metrics_port "9090")
  (crio_pause_image (jinja "{{ pod_infra_image_repo }}") ":" (jinja "{{ pod_infra_version }}"))
  (crio_registries (list))
  (crio_registry_auth (list))
  (crio_seccomp_profile "")
  (crio_selinux (jinja "{{ (preinstall_selinux_state == 'enforcing') | lower }}"))
  (crio_signature_policy (jinja "{% if ansible_os_family == 'ClearLinux' %}") "/usr/share/defaults/crio/policy.json" (jinja "{% endif %}"))
  (crio_pull_progress_timeout "10s")
  (crio_stream_port "10010")
  (crio_required_version (jinja "{{ kube_version | regex_replace('^(?P<major>\\\\d+).(?P<minor>\\\\d+).(?P<patch>\\\\d+)$', '\\\\g<major>.\\\\g<minor>') }}"))
  (crio_root "/var/lib/containers/storage")
  (crio_runtimes (list
      
      (name "crun")
      (path (jinja "{{ crio_runtime_bin_dir }}") "/crun")
      (type "oci")
      (root "/run/crun")))
  (kata_runtimes (list
      
      (name "kata-qemu")
      (path "/usr/local/bin/containerd-shim-kata-qemu-v2")
      (type "vm")
      (root "/run/kata-containers")
      (privileged_without_host_devices "true")))
  (runc_runtime 
    (name "runc")
    (path (jinja "{{ crio_runtime_bin_dir }}") "/runc")
    (type "oci")
    (root "/run/runc"))
  (crun_runtime 
    (name "crun")
    (path (jinja "{{ crio_runtime_bin_dir }}") "/crun")
    (type "oci")
    (root "/run/crun"))
  (youki_runtime 
    (name "youki")
    (path (jinja "{{ youki_bin_dir }}") "/youki")
    (type "oci")
    (root "/run/youki"))
  (crio_remap_enable "false")
  (crio_remap_user "containers")
  (crio_subuid_start "2130706432")
  (crio_subuid_length "16777216")
  (crio_subgid_start "2130706432")
  (crio_subgid_length "16777216")
  (crio_man_files 
    (5 (list
        "crio.conf"
        "crio.conf.d"))
    (8 (list
        "crio"
        "crio-status")))
  (crio_criu_support_enabled "false")
  (crio_default_capabilities (list
      "CHOWN"
      "DAC_OVERRIDE"
      "FSETID"
      "FOWNER"
      "SETGID"
      "SETUID"
      "SETPCAP"
      "NET_BIND_SERVICE"
      "KILL"))
  (crio_additional_mounts (list)))
