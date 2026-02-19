(playbook "kubespray/roles/kubernetes/preinstall/tasks/0062-networkmanager-unmanaged-devices.yml"
  (tasks
    (task "NetworkManager | Ensure NetworkManager conf.d dir"
      (file 
        (path "/etc/NetworkManager/conf.d")
        (state "directory")
        (recurse "true")))
    (task "NetworkManager | Prevent NetworkManager from managing Calico interfaces (cali*/tunl*/vxlan.calico)"
      (copy 
        (content "[keyfile]
unmanaged-devices+=interface-name:cali*;interface-name:tunl*;interface-name:vxlan.calico;interface-name:vxlan-v6.calico
")
        (dest "/etc/NetworkManager/conf.d/calico.conf")
        (mode "0644"))
      (when (list
          "kube_network_plugin == \"calico\""))
      (notify "Preinstall | reload NetworkManager"))
    (task "NetworkManager | Prevent NetworkManager from managing K8S interfaces (kube-ipvs0/nodelocaldns)"
      (copy 
        (content "[keyfile]
unmanaged-devices+=interface-name:kube-ipvs0;interface-name:nodelocaldns
")
        (dest "/etc/NetworkManager/conf.d/k8s.conf")
        (mode "0644"))
      (notify "Preinstall | reload NetworkManager"))))
