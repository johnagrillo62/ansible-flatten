(playbook "kubespray/roles/container-engine/cri-o/handlers/main.yml"
  (tasks
    (task "CRI-O | reload systemd"
      (systemd_service 
        (daemon_reload "true"))
      (listen "Restart crio"))
    (task "CRI-O | reload crio"
      (service 
        (name "crio")
        (state "restarted")
        (enabled "true"))
      (listen "Restart crio"))))
