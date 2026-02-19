(playbook "kubespray/roles/container-engine/cri-o/tasks/reset.yml"
  (tasks
    (task "Cri-o | load vars"
      (import_tasks "load_vars.yml"))
    (task "CRI-O | Kubic repo name for debian os family"
      (set_fact 
        (crio_kubic_debian_repo_name (jinja "{{ ((ansible_distribution == 'Ubuntu') | ternary('x', '')) ~ ansible_distribution ~ '_' ~ ansible_distribution_version }}")))
      (when "ansible_os_family == \"Debian\"")
      (tags (list
          "reset_crio")))
    (task "CRI-O | Remove kubic apt repo"
      (apt_repository 
        (repo "deb http://" (jinja "{{ crio_download_base }}") "/" (jinja "{{ crio_kubic_debian_repo_name }}") "/ /")
        (state "absent"))
      (when "crio_kubic_debian_repo_name is defined")
      (tags (list
          "reset_crio")))
    (task "CRI-O | Remove cri-o apt repo"
      (apt_repository 
        (repo "deb " (jinja "{{ crio_download_crio }}") "v" (jinja "{{ crio_version }}") "/" (jinja "{{ crio_kubic_debian_repo_name }}") "/ /")
        (state "absent")
        (filename "devel-kubic-libcontainers-stable-cri-o"))
      (when "crio_kubic_debian_repo_name is defined")
      (tags (list
          "reset_crio")))
    (task "CRI-O | Remove CRI-O kubic yum repo"
      (yum_repository 
        (name "devel_kubic_libcontainers_stable")
        (state "absent"))
      (when "ansible_distribution in [\"Amazon\"]")
      (tags (list
          "reset_crio")))
    (task "CRI-O | Remove CRI-O kubic yum repo"
      (yum_repository 
        (name "devel_kubic_libcontainers_stable_cri-o_v" (jinja "{{ crio_version }}"))
        (state "absent"))
      (when (list
          "ansible_os_family == \"RedHat\""
          "ansible_distribution not in [\"Amazon\", \"Fedora\"]"))
      (tags (list
          "reset_crio")))
    (task "CRI-O | Run yum-clean-metadata"
      (command "yum clean metadata")
      (when (list
          "ansible_os_family == \"RedHat\""))
      (tags (list
          "reset_crio")))
    (task "CRI-O | Remove crictl"
      (file 
        (name (jinja "{{ item }}"))
        (state "absent"))
      (loop (list
          "/etc/crictl.yaml"
          (jinja "{{ bin_dir }}") "/crictl"))
      (tags (list
          "reset_crio")))
    (task "CRI-O | Stop crio service"
      (service 
        (name "crio")
        (daemon_reload "true")
        (enabled "false")
        (state "stopped"))
      (tags (list
          "reset_crio")))
    (task "CRI-O | Remove CRI-O configuration files"
      (file 
        (name (jinja "{{ item }}"))
        (state "absent"))
      (loop (list
          "/etc/crio"
          "/etc/containers"
          "/etc/systemd/system/crio.service.d"))
      (tags (list
          "reset_crio")))
    (task "CRI-O | Remove CRI-O binaries"
      (file 
        (name (jinja "{{ item }}"))
        (state "absent"))
      (with_items (jinja "{{ crio_bin_files }}"))
      (tags (list
          "reset_crio")))
    (task "CRI-O | Remove CRI-O libexec"
      (file 
        (name (jinja "{{ item }}"))
        (state "absent"))
      (with_items (jinja "{{ crio_libexec_files }}"))
      (tags (list
          "reset_crio")))))
