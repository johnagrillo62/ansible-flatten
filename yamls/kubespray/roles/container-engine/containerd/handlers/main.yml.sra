(playbook "kubespray/roles/container-engine/containerd/handlers/main.yml"
  (tasks
    (task "Containerd | restart containerd"
      (systemd_service 
        (name "containerd")
        (state "restarted")
        (enabled "true")
        (daemon-reload "true")
        (masked "false"))
      (listen "Restart containerd"))
    (task "Containerd | wait for containerd"
      (command (jinja "{{ containerd_bin_dir }}") "/ctr images ls -q")
      (listen "Restart containerd")
      (register "containerd_ready")
      (retries "8")
      (delay "4")
      (until "containerd_ready.rc == 0"))))
