(playbook "ansible-for-devops/kubernetes/examples/files/tiller-rbac.yml"
  (apiVersion "rbac.authorization.k8s.io/v1")
  (kind "ClusterRoleBinding")
  (metadata 
    (name "tiller"))
  (roleRef 
    (apiGroup "rbac.authorization.k8s.io")
    (kind "ClusterRole")
    (name "cluster-admin"))
  (subjects (list
      
      (kind "ServiceAccount")
      (name "tiller")
      (namespace "kube-system"))))
