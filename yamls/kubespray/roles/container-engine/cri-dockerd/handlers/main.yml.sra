(playbook "kubespray/roles/container-engine/cri-dockerd/handlers/main.yml"
  (tasks
    (task "Cri-dockerd | reload systemd"
      (systemd_service 
        (name "cri-dockerd")
        (daemon_reload "true")
        (masked "false"))
      (listen "Restart and enable cri-dockerd"))
    (task "Cri-dockerd | reload cri-dockerd.socket"
      (service 
        (name "cri-dockerd.socket")
        (state "restarted"))
      (listen "Restart and enable cri-dockerd"))
    (task "Cri-dockerd | reload cri-dockerd.service"
      (service 
        (name "cri-dockerd.service")
        (state "restarted"))
      (listen "Restart and enable cri-dockerd"))
    (task "Cri-dockerd | enable cri-dockerd service"
      (service 
        (name "cri-dockerd.service")
        (enabled "true"))
      (listen "Restart and enable cri-dockerd"))))
