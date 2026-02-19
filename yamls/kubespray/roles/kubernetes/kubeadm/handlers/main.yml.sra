(playbook "kubespray/roles/kubernetes/kubeadm/handlers/main.yml"
  (tasks
    (task "Kubeadm | reload systemd"
      (systemd_service 
        (daemon_reload "true"))
      (listen "Kubeadm | restart kubelet"))
    (task "Kubeadm | reload kubelet"
      (service 
        (name "kubelet")
        (state "restarted"))
      (listen "Kubeadm | restart kubelet"))))
