(playbook "kubespray/roles/container-engine/docker/tasks/pre-upgrade.yml"
  (tasks
    (task "Remove legacy docker repo file"
      (file 
        (path (jinja "{{ yum_repo_dir }}") "/docker.repo")
        (state "absent"))
      (when (list
          "ansible_os_family == 'RedHat'"
          "not is_ostree")))
    (task "Ensure old versions of Docker are not installed. | Debian"
      (apt 
        (name (jinja "{{ docker_remove_packages_apt }}"))
        (state "absent"))
      (when (list
          "ansible_os_family == 'Debian'"
          "(docker_versioned_pkg[docker_version | string] is search('docker-ce'))")))
    (task "Ensure podman not installed. | RedHat"
      (package 
        (name (jinja "{{ podman_remove_packages_yum }}"))
        (state "absent"))
      (when (list
          "ansible_os_family == 'RedHat'"
          "(docker_versioned_pkg[docker_version | string] is search('docker-ce'))"
          "not is_ostree")))
    (task "Ensure old versions of Docker are not installed. | RedHat"
      (package 
        (name (jinja "{{ docker_remove_packages_yum }}"))
        (state "absent"))
      (when (list
          "ansible_os_family == 'RedHat'"
          "(docker_versioned_pkg[docker_version | string] is search('docker-ce'))"
          "not is_ostree")))))
