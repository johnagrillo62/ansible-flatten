(playbook "kubespray/roles/helm-apps/meta/main.yml"
  (dependencies (list
      
      (role "kubernetes-apps/helm"))))
