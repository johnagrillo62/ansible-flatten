(playbook "kubespray/roles/validate_inventory/meta/main.yml"
  (dependencies (list
      
      (role "kubespray_defaults"))))
