(playbook "kubespray/roles/kubernetes-apps/common_crds/meta/main.yml"
  (dependencies (list
      
      (role "kubernetes-apps/common_crds/gateway_api")
      (when "gateway_api_enabled")
      (tags (list
          "gateway_api"))
      
      (role "kubernetes-apps/common_crds/prometheus_operator_crds")
      (when "prometheus_operator_crds_enabled")
      (tags (list
          "prometheus_operator_crds")))))
