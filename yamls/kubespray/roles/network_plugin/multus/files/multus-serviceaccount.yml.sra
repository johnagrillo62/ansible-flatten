(playbook "kubespray/roles/network_plugin/multus/files/multus-serviceaccount.yml"
  (apiVersion "v1")
  (kind "ServiceAccount")
  (metadata 
    (name "multus")
    (namespace "kube-system")))
