(playbook "kubespray/roles/container-engine/docker/defaults/main.yml"
  (docker_version "28.3")
  (docker_cli_version (jinja "{{ docker_version }}"))
  (docker_package_info 
    (pkgs null))
  (docker_repo_key_info 
    (repo_keys null))
  (docker_repo_info 
    (repos null))
  (docker_cgroup_driver "systemd")
  (docker_bin_dir "/usr/bin")
  (docker_orphan_clean_up "false")
  (docker_remove_packages_yum (list
      "docker"
      "docker-common"
      "docker-engine"
      "docker-selinux.noarch"
      "docker-client"
      "docker-client-latest"
      "docker-latest"
      "docker-latest-logrotate"
      "docker-logrotate"
      "docker-engine-selinux.noarch"))
  (podman_remove_packages_yum (list
      "podman"))
  (docker_remove_packages_apt (list
      "docker"
      "docker-engine"
      "docker.io"))
  (containerd_package_info 
    (pkgs null))
  (docker_fedora_repo_base_url "https://download.docker.com/linux/fedora/" (jinja "{{ ansible_distribution_major_version }}") "/$basearch/stable")
  (docker_fedora_repo_gpgkey "https://download.docker.com/linux/fedora/gpg")
  (docker_rh_repo_base_url "https://download.docker.com/linux/rhel/" (jinja "{{ ansible_distribution_major_version }}") "/$basearch/stable")
  (docker_rh_repo_gpgkey "https://download.docker.com/linux/rhel/gpg")
  (docker_ubuntu_repo_base_url "https://download.docker.com/linux/ubuntu")
  (docker_ubuntu_repo_gpgkey "https://download.docker.com/linux/ubuntu/gpg")
  (docker_ubuntu_repo_repokey "9DC858229FC7DD38854AE2D88D81803C0EBFCD88")
  (docker_debian_repo_base_url "https://download.docker.com/linux/debian")
  (docker_debian_repo_gpgkey "https://download.docker.com/linux/debian/gpg")
  (docker_debian_repo_repokey "9DC858229FC7DD38854AE2D88D81803C0EBFCD88"))
