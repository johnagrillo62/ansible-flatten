(playbook "kubespray/roles/container-engine/containerd/tasks/reset.yml"
  (tasks
    (task "Containerd | Stop containerd service"
      (service 
        (name "containerd")
        (daemon_reload "true")
        (enabled "false")
        (state "stopped"))
      (tags (list
          "reset_containerd")))
    (task "Containerd | Remove configuration files"
      (file 
        (path (jinja "{{ item }}"))
        (state "absent"))
      (loop (list
          "/etc/systemd/system/containerd.service"
          (jinja "{{ containerd_systemd_dir }}")
          (jinja "{{ containerd_cfg_dir }}")
          (jinja "{{ containerd_storage_dir }}")
          (jinja "{{ containerd_state_dir }}")))
      (tags (list
          "reset_containerd")))))
