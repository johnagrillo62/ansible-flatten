(playbook "kubespray/roles/network_plugin/multus/meta/main.yml"
  (dependencies (list
      
      (role "network_plugin/cni"))))
