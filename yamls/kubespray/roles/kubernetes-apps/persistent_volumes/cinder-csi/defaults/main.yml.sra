(playbook "kubespray/roles/kubernetes-apps/persistent_volumes/cinder-csi/defaults/main.yml"
  (storage_classes (list
      
      (name "cinder-csi")
      (is_default "false")
      (parameters 
        (availability "nova")
        (allowVolumeExpansion "false")))))
