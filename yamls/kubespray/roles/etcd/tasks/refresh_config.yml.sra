(playbook "kubespray/roles/etcd/tasks/refresh_config.yml"
  (tasks
    (task "Refresh config | Create etcd config file"
      (template 
        (src "etcd.env.j2")
        (dest "/etc/etcd.env")
        (mode "0640"))
      (notify "Restart etcd")
      (when (list
          "('etcd' in group_names)"
          "etcd_cluster_setup")))
    (task "Refresh config | Create etcd-events config file"
      (template 
        (src "etcd-events.env.j2")
        (dest "/etc/etcd-events.env")
        (mode "0640"))
      (notify "Restart etcd-events")
      (when (list
          "('etcd' in group_names)"
          "etcd_events_cluster_setup")))))
