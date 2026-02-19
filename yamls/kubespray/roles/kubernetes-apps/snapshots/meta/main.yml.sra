(playbook "kubespray/roles/kubernetes-apps/snapshots/meta/main.yml"
  (dependencies (list
      
      (role "kubernetes-apps/snapshots/snapshot-controller")
      (when (list
          "cinder_csi_enabled or csi_snapshot_controller_enabled"))
      (tags (list
          "snapshot-controller"))
      
      (role "kubernetes-apps/snapshots/cinder-csi")
      (when (list
          "cinder_csi_enabled"))
      (tags (list
          "snapshot"
          "cinder-csi-driver")))))
