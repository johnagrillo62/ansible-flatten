(playbook "kubespray/tests/files/ubuntu24-flannel.yml"
  (cloud_image "ubuntu-2404")
  (cluster_layout (list
      
      (node_groups (list
          "kube_control_plane"
          "etcd"
          "kube_node"))
      
      (node_groups (list
          "kube_control_plane"
          "etcd"
          "kube_node"))
      
      (node_groups (list
          "etcd"
          "kube_node"))))
  (kube_network_plugin "flannel"))
