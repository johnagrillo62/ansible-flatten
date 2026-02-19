(playbook "kubespray/roles/kubernetes/node/handlers/main.yml"
  (tasks
    (task "Kubelet | reload systemd"
      (systemd_service 
        (daemon_reload "true"))
      (listen "Node | restart kubelet"))
    (task "Kubelet | restart kubelet"
      (service 
        (name "kubelet")
        (state "restarted"))
      (listen "Node | restart kubelet"))))
