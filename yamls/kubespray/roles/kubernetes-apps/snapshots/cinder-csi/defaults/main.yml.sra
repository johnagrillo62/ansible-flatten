(playbook "kubespray/roles/kubernetes-apps/snapshots/cinder-csi/defaults/main.yml"
  (snapshot_classes (list
      
      (name "cinder-csi-snapshot")
      (is_default "false")
      (force_create "true")
      (deletionPolicy "Delete"))))
