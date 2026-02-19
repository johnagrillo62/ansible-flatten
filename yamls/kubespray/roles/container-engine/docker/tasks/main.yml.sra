(playbook "kubespray/roles/container-engine/docker/tasks/main.yml"
  (tasks
    (task "Check if fedora coreos"
      (stat 
        (path "/run/ostree-booted")
        (get_attributes "false")
        (get_checksum "false")
        (get_mime "false"))
      (register "ostree"))
    (task "Set is_ostree"
      (set_fact 
        (is_ostree (jinja "{{ ostree.stat.exists }}"))))
    (task "Gather os specific variables"
      (include_vars (jinja "{{ item }}"))
      (with_first_found (list
          
          (files (list
              (jinja "{{ ansible_distribution | lower }}") "-" (jinja "{{ ansible_distribution_version | lower | replace('/', '_') }}") ".yml"
              (jinja "{{ ansible_distribution | lower }}") "-" (jinja "{{ ansible_distribution_release | lower }}") "-" (jinja "{{ host_architecture }}") ".yml"
              (jinja "{{ ansible_distribution | lower }}") "-" (jinja "{{ ansible_distribution_release | lower }}") ".yml"
              (jinja "{{ ansible_distribution | lower }}") "-" (jinja "{{ ansible_distribution_major_version | lower | replace('/', '_') }}") ".yml"
              (jinja "{{ ansible_distribution | lower }}") "-" (jinja "{{ host_architecture }}") ".yml"
              (jinja "{{ ansible_distribution | lower }}") ".yml"
              (jinja "{{ ansible_distribution.split(' ')[0] | lower }}") ".yml"
              (jinja "{{ ansible_os_family | lower }}") "-" (jinja "{{ ansible_distribution_major_version | lower | replace('/', '_') }}") ".yml"
              (jinja "{{ ansible_os_family | lower }}") "-" (jinja "{{ host_architecture }}") ".yml"
              (jinja "{{ ansible_os_family | lower }}") ".yml"
              "defaults.yml"))
          (paths (list
              "../vars"))
          (skip "true")))
      (tags (list
          "facts")))
    (task "Warn about Docker version on SUSE"
      (debug 
        (msg "SUSE distributions always install Docker from the distro repos"))
      (when "ansible_pkg_mgr == 'zypper'"))
    (task "Gather DNS facts"
      (include_tasks "set_facts_dns.yml")
      (when "dns_mode != 'none' and resolvconf_mode == 'docker_dns'")
      (tags (list
          "facts")))
    (task "Pre-upgrade docker"
      (import_tasks "pre-upgrade.yml"))
    (task "Ensure docker-ce repository public key is installed"
      (apt_key 
        (id (jinja "{{ item }}"))
        (url (jinja "{{ docker_repo_key_info.url }}"))
        (keyring (jinja "{{ docker_repo_key_keyring | default(omit) }}"))
        (state "present"))
      (register "keyserver_task_result")
      (until "keyserver_task_result is succeeded")
      (retries "4")
      (delay (jinja "{{ retry_stagger }}"))
      (with_items (jinja "{{ docker_repo_key_info.repo_keys }}"))
      (environment (jinja "{{ proxy_env }}"))
      (when "ansible_pkg_mgr == 'apt'"))
    (task "Convert -backports sources to archive.debian.org for bullseye and older"
      (replace 
        (path (jinja "{{ item }}"))
        (regexp "^(deb(?:-src)?\\s+)(?:https?://)?(?:[^ ]+debian\\.org)?([^ ]*/debian)(\\s+" (jinja "{{ ansible_distribution_release }}") "-backports\\b.*)")
        (replace "\\1http://archive.debian.org/debian\\3")
        (backup "true"))
      (loop (jinja "{{ query('fileglob', '/etc/apt/sources.list') }}"))
      (when (list
          "ansible_os_family == 'Debian'"
          "ansible_distribution_release in ['bullseye', 'buster']")))
    (task "Ensure docker-ce repository is enabled"
      (apt_repository 
        (repo (jinja "{{ item }}"))
        (state "present"))
      (with_items (jinja "{{ docker_repo_info.repos }}"))
      (when "ansible_pkg_mgr == 'apt'"))
    (task "Configure docker repository on Fedora"
      (template 
        (src "fedora_docker.repo.j2")
        (dest (jinja "{{ yum_repo_dir }}") "/docker.repo")
        (mode "0644"))
      (when "ansible_distribution == \"Fedora\" and not is_ostree"))
    (task "Configure docker repository on RedHat/CentOS/OracleLinux/AlmaLinux/KylinLinux"
      (template 
        (src "rh_docker.repo.j2")
        (dest (jinja "{{ yum_repo_dir }}") "/docker-ce.repo")
        (mode "0644"))
      (when (list
          "ansible_os_family == \"RedHat\""
          "ansible_distribution != \"Fedora\""
          "not is_ostree")))
    (task "Remove dpkg hold"
      (dpkg_selections 
        (name (jinja "{{ item }}"))
        (selection "install"))
      (when "ansible_pkg_mgr == 'apt'")
      (register "ret")
      (changed_when "false")
      (failed_when (list
          "ret is failed"
          "ret.msg != ( \"Failed to find package '\" + item + \"' to perform selection 'install'.\" )"))
      (with_items (list
          (jinja "{{ containerd_package }}")
          "docker-ce"
          "docker-ce-cli")))
    (task "Ensure docker packages are installed"
      (package 
        (name (jinja "{{ docker_package_info.pkgs }}"))
        (state (jinja "{{ docker_package_info.state | default('present') }}")))
      (module_defaults 
        (apt 
          (update_cache "true"))
        (dnf 
          (enablerepo (jinja "{{ docker_package_info.enablerepo | default(omit) }}"))
          (disablerepo (jinja "{{ docker_package_info.disablerepo | default(omit) }}")))
        (yum 
          (enablerepo (jinja "{{ docker_package_info.enablerepo | default(omit) }}")))
        (zypper 
          (update_cache "true")))
      (register "docker_task_result")
      (until "docker_task_result is succeeded")
      (retries "4")
      (delay (jinja "{{ retry_stagger }}"))
      (notify "Restart docker")
      (when (list
          "not ansible_os_family in [\"Flatcar\", \"Flatcar Container Linux by Kinvolk\"]"
          "not is_ostree"
          "docker_package_info.pkgs | length > 0")))
    (task "Tell Debian hosts not to change the docker version with apt upgrade"
      (dpkg_selections 
        (name (jinja "{{ item }}"))
        (selection "hold"))
      (when "ansible_pkg_mgr == 'apt'")
      (changed_when "false")
      (with_items (list
          (jinja "{{ containerd_package }}")
          "docker-ce"
          "docker-ce-cli")))
    (task "Ensure docker started, remove our config if docker start failed and try again"
      (block (list
          
          (name "Ensure service is started if docker packages are already present")
          (service 
            (name "docker")
            (state "started"))
          (when "docker_task_result is not changed")))
      (rescue (list
          
          (debug 
            (msg "Docker start failed. Try to remove our config"))
          
          (name "Remove kubespray generated config")
          (file 
            (path (jinja "{{ item }}"))
            (state "absent"))
          (with_items (list
              "/etc/systemd/system/docker.service.d/http-proxy.conf"
              "/etc/systemd/system/docker.service.d/docker-options.conf"
              "/etc/systemd/system/docker.service.d/docker-dns.conf"
              "/etc/systemd/system/docker.service.d/docker-orphan-cleanup.conf"))
          (notify "Restart docker"))))
    (task "Flush handlers so we can wait for docker to come up"
      (meta "flush_handlers"))
    (task "Install docker plugin"
      (include_tasks "docker_plugin.yml")
      (loop (jinja "{{ docker_plugins }}"))
      (loop_control 
        (loop_var "docker_plugin")))
    (task "Set docker systemd config"
      (import_tasks "systemd.yml"))
    (task "Ensure docker service is started and enabled"
      (service 
        (name (jinja "{{ item }}"))
        (enabled "true")
        (state "started"))
      (with_items (list
          "docker")))))
