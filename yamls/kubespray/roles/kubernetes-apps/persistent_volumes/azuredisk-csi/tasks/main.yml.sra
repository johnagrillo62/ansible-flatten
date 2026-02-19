(playbook "kubespray/roles/kubernetes-apps/persistent_volumes/azuredisk-csi/tasks/main.yml"
  (tasks
    (task "Kubernetes Persistent Volumes | Copy Azure CSI Storage Class template"
      (template 
        (src "azure-csi-storage-class.yml.j2")
        (dest (jinja "{{ kube_config_dir }}") "/azure-csi-storage-class.yml")
        (mode "0644"))
      (register "manifests")
      (when (list
          "inventory_hostname == groups['kube_control_plane'][0]")))
    (task "Kubernetes Persistent Volumes | Add Azure CSI Storage Class"
      (kube 
        (name "azure-csi")
        (kubectl (jinja "{{ bin_dir }}") "/kubectl")
        (resource "StorageClass")
        (filename (jinja "{{ kube_config_dir }}") "/azure-csi-storage-class.yml")
        (state "latest"))
      (when (list
          "inventory_hostname == groups['kube_control_plane'][0]"
          "manifests.changed")))))
