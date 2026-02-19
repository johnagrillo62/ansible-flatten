(playbook "kubespray/tests/files/ubuntu24-crio-scale.yml"
  (cloud_image "ubuntu-2404")
  (container_manager "crio")
  (cluster_layout (list
      
      (node_groups (list
          "kube_control_plane"
          "etcd"))
      
      (node_groups (list
          "kube_node"))
      
      (node_groups (list
          "kube_node"
          "for_scale")))))
