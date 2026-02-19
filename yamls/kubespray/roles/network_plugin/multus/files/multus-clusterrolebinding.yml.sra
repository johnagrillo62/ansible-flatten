(playbook "kubespray/roles/network_plugin/multus/files/multus-clusterrolebinding.yml"
  (kind "ClusterRoleBinding")
  (apiVersion "rbac.authorization.k8s.io/v1")
  (metadata 
    (name "multus"))
  (roleRef 
    (apiGroup "rbac.authorization.k8s.io")
    (kind "ClusterRole")
    (name "multus"))
  (subjects (list
      
      (kind "ServiceAccount")
      (name "multus")
      (namespace "kube-system"))))
