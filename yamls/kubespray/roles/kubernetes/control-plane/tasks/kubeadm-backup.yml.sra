(playbook "kubespray/roles/kubernetes/control-plane/tasks/kubeadm-backup.yml"
  (tasks
    (task "Backup old certs and keys"
      (copy 
        (src (jinja "{{ kube_cert_dir }}") "/" (jinja "{{ item }}"))
        (dest (jinja "{{ kube_cert_dir }}") "/" (jinja "{{ item }}") ".old")
        (mode "preserve")
        (remote_src "true"))
      (with_items (list
          "apiserver.crt"
          "apiserver.key"
          "apiserver-kubelet-client.crt"
          "apiserver-kubelet-client.key"
          "front-proxy-client.crt"
          "front-proxy-client.key"))
      (ignore_errors "true"))
    (task "Backup old confs"
      (copy 
        (src (jinja "{{ kube_config_dir }}") "/" (jinja "{{ item }}"))
        (dest (jinja "{{ kube_config_dir }}") "/" (jinja "{{ item }}") ".old")
        (mode "preserve")
        (remote_src "true"))
      (with_items (list
          "admin.conf"
          "controller-manager.conf"
          "kubelet.conf"
          "scheduler.conf"))
      (ignore_errors "true"))))
