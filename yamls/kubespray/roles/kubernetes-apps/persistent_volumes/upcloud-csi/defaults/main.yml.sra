(playbook "kubespray/roles/kubernetes-apps/persistent_volumes/upcloud-csi/defaults/main.yml"
  (storage_classes (list
      
      (name "standard")
      (is_default "true")
      (expand_persistent_volumes "true")
      (parameters 
        (tier "maxiops"))
      
      (name "hdd")
      (is_default "false")
      (expand_persistent_volumes "true")
      (parameters 
        (tier "hdd")))))
