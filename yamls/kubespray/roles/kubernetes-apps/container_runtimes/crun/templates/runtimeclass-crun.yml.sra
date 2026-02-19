(playbook "kubespray/roles/kubernetes-apps/container_runtimes/crun/templates/runtimeclass-crun.yml"
  (kind "RuntimeClass")
  (apiVersion "node.k8s.io/v1")
  (metadata 
    (name "crun"))
  (handler "crun"))
