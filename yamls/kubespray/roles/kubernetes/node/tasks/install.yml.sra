(playbook "kubespray/roles/kubernetes/node/tasks/install.yml"
  (tasks
    (task "Install | Copy kubeadm binary from download dir"
      (copy 
        (src (jinja "{{ downloads.kubeadm.dest }}"))
        (dest (jinja "{{ bin_dir }}") "/kubeadm")
        (mode "0755")
        (remote_src "true"))
      (tags (list
          "kubeadm"))
      (when (list
          "not ('kube_control_plane' in group_names)")))
    (task "Install | Copy kubelet binary from download dir"
      (copy 
        (src (jinja "{{ downloads.kubelet.dest }}"))
        (dest (jinja "{{ bin_dir }}") "/kubelet")
        (mode "0755")
        (remote_src "true"))
      (tags (list
          "kubelet"
          "upgrade"))
      (notify "Node | restart kubelet"))))
