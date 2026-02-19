(playbook "kubespray/roles/network_plugin/macvlan/meta/main.yml"
  (dependencies (list
      
      (role "network_plugin/cni"))))
