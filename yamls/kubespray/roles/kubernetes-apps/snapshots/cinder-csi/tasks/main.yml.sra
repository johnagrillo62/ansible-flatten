(playbook "kubespray/roles/kubernetes-apps/snapshots/cinder-csi/tasks/main.yml"
  (tasks
    (task "Kubernetes Snapshots | Copy Cinder CSI Snapshot Class template"
      (template 
        (src "cinder-csi-snapshot-class.yml.j2")
        (dest (jinja "{{ kube_config_dir }}") "/cinder-csi-snapshot-class.yml")
        (mode "0644"))
      (register "manifests")
      (when (list
          "inventory_hostname == groups['kube_control_plane'][0]")))
    (task "Kubernetes Snapshots | Add Cinder CSI Snapshot Class"
      (kube 
        (kubectl (jinja "{{ bin_dir }}") "/kubectl")
        (filename (jinja "{{ kube_config_dir }}") "/cinder-csi-snapshot-class.yml")
        (state "latest"))
      (when (list
          "inventory_hostname == groups['kube_control_plane'][0]"
          "manifests.changed")))))
