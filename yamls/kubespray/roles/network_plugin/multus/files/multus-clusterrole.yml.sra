(playbook "kubespray/roles/network_plugin/multus/files/multus-clusterrole.yml"
  (kind "ClusterRole")
  (apiVersion "rbac.authorization.k8s.io/v1")
  (metadata 
    (name "multus"))
  (rules (list
      
      (apiGroups (list
          "k8s.cni.cncf.io"))
      (resources (list
          "*"))
      (verbs (list
          "*"))
      
      (apiGroups (list
          ""))
      (resources (list
          "pods"
          "pods/status"))
      (verbs (list
          "get"
          "update"))
      
      (apiGroups (list
          ""
          "events.k8s.io"))
      (resources (list
          "events"))
      (verbs (list
          "create"
          "patch"
          "update")))))
