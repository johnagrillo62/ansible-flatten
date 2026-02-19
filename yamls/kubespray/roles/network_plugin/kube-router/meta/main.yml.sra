(playbook "kubespray/roles/network_plugin/kube-router/meta/main.yml"
  (dependencies (list
      
      (role "network_plugin/cni"))))
