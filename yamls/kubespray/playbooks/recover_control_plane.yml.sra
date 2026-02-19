(playbook "kubespray/playbooks/recover_control_plane.yml"
  (tasks
    (task "Common tasks for every playbooks"
      (import_playbook "boilerplate.yml"))
    (task "Recover etcd"
      (hosts "etcd[0]")
      (roles (list
          
          (role "kubespray_defaults")
          
          (role "recover_control_plane/etcd")
          (when "etcd_deployment_type != \"kubeadm\"")))
      (environment (jinja "{{ proxy_disable_env }}")))
    (task "Recover control plane"
      (hosts "kube_control_plane[0]")
      (roles (list
          
          (role "kubespray_defaults")
          
          (role "recover_control_plane/control-plane")))
      (environment (jinja "{{ proxy_disable_env }}")))
    (task "Apply whole cluster install"
      (import_playbook "cluster.yml"))
    (task "Perform post recover tasks"
      (hosts "kube_control_plane")
      (roles (list
          
          (role "kubespray_defaults")
          
          (role "recover_control_plane/post-recover")))
      (environment (jinja "{{ proxy_disable_env }}")))))
