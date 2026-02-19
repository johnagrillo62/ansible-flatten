(playbook "kubespray/tests/files/fedora40-flannel-crio-collection-scale.yml"
  (cloud_image "fedora-40")
  (network_plugin "flannel")
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
