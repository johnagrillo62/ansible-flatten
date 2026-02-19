(playbook "kubespray/roles/network_plugin/calico/meta/main.yml"
  (dependencies (list
      
      (role "network_plugin/calico_defaults"))))
