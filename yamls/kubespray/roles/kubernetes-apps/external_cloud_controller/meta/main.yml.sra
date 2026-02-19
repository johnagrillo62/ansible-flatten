(playbook "kubespray/roles/kubernetes-apps/external_cloud_controller/meta/main.yml"
  (dependencies (list
      
      (role "kubernetes-apps/external_cloud_controller/openstack")
      (when (list
          "cloud_provider == \"external\""
          "external_cloud_provider == \"openstack\""
          "inventory_hostname == groups['kube_control_plane'][0]"))
      (tags (list
          "external-cloud-controller"
          "external-openstack"))
      
      (role "kubernetes-apps/external_cloud_controller/vsphere")
      (when (list
          "cloud_provider == \"external\""
          "external_cloud_provider == \"vsphere\""
          "inventory_hostname == groups['kube_control_plane'][0]"))
      (tags (list
          "external-cloud-controller"
          "external-vsphere"))
      
      (role "kubernetes-apps/external_cloud_controller/hcloud")
      (when (list
          "cloud_provider == \"external\""
          "external_cloud_provider == \"hcloud\""
          "inventory_hostname == groups['kube_control_plane'][0]"))
      (tags (list
          "external-cloud-controller"
          "external-hcloud"))
      
      (role "kubernetes-apps/external_cloud_controller/huaweicloud")
      (when (list
          "cloud_provider == \"external\""
          "external_cloud_provider == \"huaweicloud\""
          "inventory_hostname == groups['kube_control_plane'][0]"))
      (tags (list
          "external-cloud-controller"
          "external-huaweicloud"))
      
      (role "kubernetes-apps/external_cloud_controller/oci")
      (when (list
          "cloud_provider == \"external\""
          "external_cloud_provider == \"oci\""
          "inventory_hostname == groups['kube_control_plane'][0]"))
      (tags (list
          "external-cloud-controller"
          "external-oci")))))
