(playbook "kubespray/roles/bootstrap_os/meta/main.yml"
  (dependencies (list
      
      (role "kubespray_defaults"))))
