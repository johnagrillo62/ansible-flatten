(playbook "docs/container_groups/service-account.yml"
  (apiVersion "v1")
  (kind "ServiceAccount")
  (metadata 
    (name "containergroup-service-account")
    (namespace "containergroup-namespace")))
(playbook "docs/container_groups/service-account.yml"
  (kind "Role")
  (apiVersion "rbac.authorization.k8s.io/v1")
  (metadata 
    (name "role-containergroup-service-account")
    (namespace "containergroup-namespace"))
  (rules (list
      
      (apiGroups (list
          ""))
      (resources (list
          "pods"))
      (verbs (list
          "get"
          "list"
          "watch"
          "create"
          "update"
          "patch"
          "delete"))
      
      (apiGroups (list
          ""))
      (resources (list
          "pods/log"))
      (verbs (list
          "get"
          "list"
          "watch"
          "create"
          "update"
          "patch"
          "delete"))
      
      (apiGroups (list
          ""))
      (resources (list
          "pods/attach"))
      (verbs (list
          "get"
          "list"
          "watch"
          "create"
          "update"
          "patch"
          "delete")))))
(playbook "docs/container_groups/service-account.yml"
  (kind "RoleBinding")
  (apiVersion "rbac.authorization.k8s.io/v1")
  (metadata 
    (name "role-containergroup-service-account-binding")
    (namespace "containergroup-namespace"))
  (subjects (list
      
      (kind "ServiceAccount")
      (name "containergroup-service-account")
      (namespace "containergroup-namespace")))
  (roleRef 
    (kind "Role")
    (name "role-containergroup-service-account")
    (apiGroup "rbac.authorization.k8s.io")))
