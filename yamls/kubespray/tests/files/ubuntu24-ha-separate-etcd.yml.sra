(playbook "kubespray/tests/files/ubuntu24-ha-separate-etcd.yml"
  (cloud_image "ubuntu-2404")
  (cluster_layout (list
      
      (node_groups (list
          "kube_control_plane"))
      
      (node_groups (list
          "kube_control_plane"))
      
      (node_groups (list
          "kube_control_plane"))
      
      (node_groups (list
          "kube_node"))
      
      (node_groups (list
          "etcd"))
      
      (node_groups (list
          "etcd"))
      
      (node_groups (list
          "etcd"))))
  (kube_network_plugin "calico")
  (calico_datastore "etcd"))
