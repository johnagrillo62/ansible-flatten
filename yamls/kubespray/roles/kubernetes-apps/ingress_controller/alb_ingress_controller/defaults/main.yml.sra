(playbook "kubespray/roles/kubernetes-apps/ingress_controller/alb_ingress_controller/defaults/main.yml"
  (alb_ingress_controller_namespace "kube-system")
  (alb_ingress_aws_region "us-east-1")
  (alb_ingress_aws_debug "false"))
