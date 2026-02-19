(playbook "kubespray/tests/files/custom_cni/values.yaml"
  (hubble 
    (enabled "false"))
  (ipam 
    (operator 
      (clusterPoolIPv4PodCIDRList (list
          (jinja "{{ kube_pods_subnet }}"))))))
