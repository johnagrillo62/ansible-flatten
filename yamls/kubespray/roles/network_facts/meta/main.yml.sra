(playbook "kubespray/roles/network_facts/meta/main.yml"
  (dependencies (list
      
      (role "kubespray_defaults"))))
