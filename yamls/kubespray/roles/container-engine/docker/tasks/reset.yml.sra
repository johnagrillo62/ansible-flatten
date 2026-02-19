(playbook "kubespray/roles/container-engine/docker/tasks/reset.yml"
  (tasks
    (task "Docker | Get package facts"
      (package_facts 
        (manager "auto")))
    (task "Docker | Find docker packages"
      (set_fact 
        (docker_packages_list (jinja "{{ ansible_facts.packages.keys() | select('search', '^docker+') }}"))
        (containerd_package (jinja "{{ ansible_facts.packages.keys() | select('search', '^containerd+') }}"))))
    (task "Docker | Stop all running container"
      (shell "set -o pipefail && " (jinja "{{ docker_bin_dir }}") "/docker ps -q | xargs -r " (jinja "{{ docker_bin_dir }}") "/docker kill")
      (args 
        (executable "/bin/bash"))
      (register "stop_all_containers")
      (retries "5")
      (until "stop_all_containers.rc == 0")
      (changed_when "true")
      (delay "5")
      (ignore_errors "true")
      (when "docker_packages_list | length>0"))
    (task "Reset | remove all containers"
      (shell "set -o pipefail && " (jinja "{{ docker_bin_dir }}") "/docker ps -aq | xargs -r docker rm -fv")
      (args 
        (executable "/bin/bash"))
      (register "remove_all_containers")
      (retries "4")
      (until "remove_all_containers.rc == 0")
      (delay "5")
      (when "docker_packages_list | length>0"))
    (task "Docker | Stop docker service"
      (service 
        (name (jinja "{{ item }}"))
        (enabled "false")
        (state "stopped"))
      (loop (list
          "docker"
          "docker.socket"
          "containerd"))
      (when "docker_packages_list | length>0"))
    (task "Docker | Remove dpkg hold"
      (dpkg_selections 
        (name (jinja "{{ item }}"))
        (selection "install"))
      (when "ansible_pkg_mgr == 'apt'")
      (changed_when "false")
      (with_items (list
          (jinja "{{ docker_packages_list }}")
          (jinja "{{ containerd_package }}"))))
    (task "Docker | Remove docker package"
      (package 
        (name (jinja "{{ item }}"))
        (state "absent"))
      (changed_when "false")
      (with_items (list
          (jinja "{{ docker_packages_list }}")
          (jinja "{{ containerd_package }}")))
      (when (list
          "not ansible_os_family in [\"Flatcar\", \"Flatcar Container Linux by Kinvolk\"]"
          "not is_ostree"
          "docker_packages_list | length > 0")))
    (task "Docker | ensure docker-ce repository is removed"
      (apt_repository 
        (repo (jinja "{{ item }}"))
        (state "absent"))
      (with_items (jinja "{{ docker_repo_info.repos }}"))
      (when "ansible_pkg_mgr == 'apt'"))
    (task "Docker | Remove docker repository on Fedora"
      (file 
        (name (jinja "{{ yum_repo_dir }}") "/docker.repo")
        (state "absent"))
      (when "ansible_distribution == \"Fedora\" and not is_ostree"))
    (task "Docker | Remove docker repository on RedHat/CentOS/Oracle/AlmaLinux Linux"
      (file 
        (name (jinja "{{ yum_repo_dir }}") "/docker-ce.repo")
        (state "absent"))
      (when (list
          "ansible_os_family == \"RedHat\""
          "ansible_distribution != \"Fedora\""
          "not is_ostree")))
    (task "Docker | Remove docker configuration files"
      (file 
        (name (jinja "{{ item }}"))
        (state "absent"))
      (loop (list
          "/etc/systemd/system/docker.service.d/"
          "/etc/systemd/system/docker.socket"
          "/etc/systemd/system/docker.service"
          "/etc/systemd/system/containerd.service"
          "/etc/systemd/system/containerd.service.d"
          "/var/lib/docker"
          "/etc/docker"))
      (ignore_errors "true"))
    (task "Docker | systemctl daemon-reload"
      (systemd_service 
        (daemon_reload "true")))))
