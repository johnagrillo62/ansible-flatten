(playbook "kubespray/roles/kubernetes-apps/ingress_controller/meta/main.yml"
  (dependencies (list
      
      (role "kubernetes-apps/ingress_controller/cert_manager")
      (when "cert_manager_enabled")
      (tags (list
          "apps"
          "ingress-controller"
          "cert-manager"))
      
      (role "kubernetes-apps/ingress_controller/alb_ingress_controller")
      (when "ingress_alb_enabled")
      (tags (list
          "apps"
          "ingress-controller"
          "ingress_alb")))))
