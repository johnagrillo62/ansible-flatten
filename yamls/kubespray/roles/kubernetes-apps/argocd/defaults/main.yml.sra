(playbook "kubespray/roles/kubernetes-apps/argocd/defaults/main.yml"
  (argocd_enabled "false")
  (argocd_version "2.14.5")
  (argocd_namespace "argocd"))
