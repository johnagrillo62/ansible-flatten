(playbook "kubespray/roles/container-engine/docker/handlers/main.yml"
  (tasks
    (task "Docker | reload systemd"
      (systemd_service 
        (name "docker")
        (daemon_reload "true")
        (masked "false"))
      (listen "Restart docker"))
    (task "Docker | reload docker.socket"
      (service 
        (name "docker.socket")
        (state "restarted"))
      (listen "Restart docker")
      (when "ansible_os_family in ['Flatcar', 'Flatcar Container Linux by Kinvolk'] or is_fedora_coreos"))
    (task "Docker | reload docker"
      (service 
        (name "docker")
        (state "restarted"))
      (listen "Restart docker"))
    (task "Docker | wait for docker"
      (command (jinja "{{ docker_bin_dir }}") "/docker images")
      (listen "Restart docker")
      (register "docker_ready")
      (retries "20")
      (delay "1")
      (until "docker_ready.rc == 0"))))
