(playbook "kubespray/roles/kubernetes-apps/container_runtimes/youki/templates/runtimeclass-youki.yml"
  (kind "RuntimeClass")
  (apiVersion "node.k8s.io/v1")
  (metadata 
    (name "youki"))
  (handler "youki"))
