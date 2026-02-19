(playbook "kubespray/tests/files/fedora41-kube-router.yml"
  (cloud_image "fedora-41")
  (cluster_layout (list
      
      (node_groups (list
          "kube_control_plane"
          "etcd"
          "kube_node"))
      
      (node_groups (list
          "kube_node"))))
  (kube_network_plugin "kube-router"))
