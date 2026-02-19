(playbook "kubespray/roles/network_plugin/flannel/meta/main.yml"
  (dependencies (list
      
      (role "network_plugin/cni"))))
