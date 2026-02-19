(playbook "kubespray/roles/kubernetes-apps/persistent_volumes/cinder-csi/tasks/main.yml"
  (tasks
    (task "Kubernetes Persistent Volumes | Copy Cinder CSI Storage Class template"
      (template 
        (src "cinder-csi-storage-class.yml.j2")
        (dest (jinja "{{ kube_config_dir }}") "/cinder-csi-storage-class.yml")
        (mode "0644"))
      (register "manifests")
      (when (list
          "inventory_hostname == groups['kube_control_plane'][0]")))
    (task "Kubernetes Persistent Volumes | Add Cinder CSI Storage Class"
      (kube 
        (name "cinder-csi")
        (kubectl (jinja "{{ bin_dir }}") "/kubectl")
        (resource "StorageClass")
        (filename (jinja "{{ kube_config_dir }}") "/cinder-csi-storage-class.yml")
        (state "latest"))
      (when (list
          "inventory_hostname == groups['kube_control_plane'][0]"
          "manifests.changed")))))
